import { useState, useEffect, useCallback, useRef } from "react";

const cache = new Map(); // in-memory for instant within-session access
const inFlight = new Map(); // de-dupe identical fetches during React dev double effects
const STORAGE_PREFIX = "swr_cache_";

function readFromStorage(key) {
  try {
    const raw = sessionStorage.getItem(STORAGE_PREFIX + key);
    if (!raw) return null;
    const { data, ts } = JSON.parse(raw);
    return { data, ts };
  } catch {
    return null;
  }
}

function writeToStorage(key, data) {
  try {
    sessionStorage.setItem(
      STORAGE_PREFIX + key,
      JSON.stringify({ data, ts: Date.now() }),
    );
  } catch {
    // storage quota — not fatal
  }
}

/**
 * Stale-While-Revalidate hook.
 *
 * @param {string} cacheKey   - unique string key for this data
 * @param {Function} fetcher  - async function that returns fresh data
 * @param {object} options
 *   @param {number}  options.ttl         - ms before data is considered stale (default 60s)
 *   @param {boolean} options.skip        - don't fetch when true (e.g. missing id)
 *   @param {any}     options.deps        - extra dependency that invalidates cache when changed
 *
 * Returns { data, loading, revalidating, error, mutate }
 *   - data:         last known data (may be stale)
 *   - loading:      true only on the very first load with no cached data
 *   - revalidating: true when a background fetch is in-flight (stale data shown)
 *   - error:        fetch error (doesn't clear existing data)
 *   - mutate:       fn(newData) to update local cache immediately (optimistic)
 */
export function useStaleData(
  cacheKey,
  fetcher,
  { ttl = 60_000, skip = false, deps } = {},
) {
  const getInitial = (k) => {
    if (cache.has(k)) return cache.get(k);
    const stored = readFromStorage(k);
    if (stored) {
      cache.set(k, stored.data);
      return stored.data;
    }
    if (k === "profile:me") {
      try {
        const local = localStorage.getItem("user_data");
        if (local) {
          const parsed = JSON.parse(local);
          cache.set(k, parsed);
          return parsed;
        }
      } catch {}
    }
    return null;
  };

  const [data, setData] = useState(() => getInitial(cacheKey));
  const [prevKey, setPrevKey] = useState(cacheKey);
  const [loading, setLoading] = useState(() => !getInitial(cacheKey) && !skip);
  const [revalidating, setRevalidating] = useState(false);
  const [error, setError] = useState(null);

  if (cacheKey !== prevKey) {
    const initial = getInitial(cacheKey);
    setData(initial);
    setPrevKey(cacheKey);
    setLoading(!initial && !skip);
    setError(null);
  }

  const fetcherRef = useRef(fetcher);
  fetcherRef.current = fetcher;

  const revalidate = useCallback(async () => {
    if (skip) return;
    const hasCache = cache.has(cacheKey);
    if (hasCache) {
      setRevalidating(true);
    } else {
      setLoading(true);
    }

    try {
      let request = inFlight.get(cacheKey);
      if (!request) {
        request = fetcherRef.current();
        inFlight.set(cacheKey, request);
      }

      const fresh = await request;
      const stored = readFromStorage(cacheKey);
      // Only update state if data actually changed (shallow JSON compare)
      if (!stored || JSON.stringify(stored.data) !== JSON.stringify(fresh)) {
        cache.set(cacheKey, fresh);
        writeToStorage(cacheKey, fresh);
        setData(fresh);
      }
      setError(null);
    } catch (err) {
      setError(err);
    } finally {
      inFlight.delete(cacheKey);
      setLoading(false);
      setRevalidating(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cacheKey, skip, deps]);

  useEffect(() => {
    revalidate();
  }, [revalidate]);

  const mutate = useCallback(
    (newData) => {
      cache.set(cacheKey, newData);
      writeToStorage(cacheKey, newData);
      setData(newData);
    },
    [cacheKey],
  );

  return { data, loading, revalidating, error, mutate, revalidate };
}

/** Invalidate a cache key so next mount forces a fresh fetch */
export function invalidateCache(cacheKey) {
  cache.delete(cacheKey);
  try {
    sessionStorage.removeItem(STORAGE_PREFIX + cacheKey);
  } catch {}
}

/** Clear all cached SWR data and optionally pre-populate profile:me */
export function clearCacheAndInitProfile(profileData) {
  cache.clear();
  try {
    const keys = [];
    for (let i = 0; i < sessionStorage.length; i++) {
      const key = sessionStorage.key(i);
      if (key && key.startsWith(STORAGE_PREFIX)) {
        keys.push(key);
      }
    }
    keys.forEach((k) => sessionStorage.removeItem(k));
  } catch {}

  if (profileData) {
    cache.set("profile:me", profileData);
    try {
      sessionStorage.setItem(
        STORAGE_PREFIX + "profile:me",
        JSON.stringify({ data: profileData, ts: Date.now() }),
      );
    } catch {}
  }
}
