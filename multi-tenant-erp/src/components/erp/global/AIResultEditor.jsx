import React from 'react';

const AIResultEditor = ({ data, onChange }) => {
  if (data === null || data === undefined) return null;

  if (typeof data === 'string') {
    return (
      <textarea
        value={data}
        onChange={(e) => onChange(e.target.value)}
        className="w-full p-3 border border-outline-variant/30 rounded-lg text-sm text-on-surface bg-surface-container-lowest focus:ring-2 focus:ring-primary/40 outline-none font-body min-h-[100px] resize-y"
      />
    );
  }

  if (typeof data === 'number') {
    return (
      <input
        type="number"
        value={data}
        onChange={(e) => onChange(Number(e.target.value))}
        className="w-full p-3 border border-outline-variant/30 rounded-lg text-sm text-on-surface bg-surface-container-lowest focus:ring-2 focus:ring-primary/40 outline-none font-body"
      />
    );
  }

  if (Array.isArray(data)) {
    return (
      <div className="space-y-4 pl-4 border-l-2 border-primary/20 mt-2 mb-2">
        {data.map((item, idx) => (
          <div key={idx} className="bg-surface-container-low p-4 rounded-xl relative group mt-3">
            <span className="absolute -top-3 left-4 bg-surface-container-low px-2 text-xs font-bold text-primary/70">
              Item {idx + 1}
            </span>
            <AIResultEditor
              data={item}
              onChange={(newVal) => {
                const newData = [...data];
                newData[idx] = newVal;
                onChange(newData);
              }}
            />
          </div>
        ))}
      </div>
    );
  }

  if (typeof data === 'object') {
    return (
      <div className="space-y-4">
        {Object.keys(data).map((key) => {
          const value = data[key];
          // Skip internal or empty fields if necessary, but usually we show all.
          return (
            <div key={key} className="space-y-1">
              <label className="text-xs font-bold text-on-surface-variant uppercase tracking-wider font-display">
                {key.replace(/_/g, ' ')}
              </label>
              <AIResultEditor
                data={value}
                onChange={(newVal) => {
                  onChange({ ...data, [key]: newVal });
                }}
              />
            </div>
          );
        })}
      </div>
    );
  }

  return null;
};

export default AIResultEditor;
