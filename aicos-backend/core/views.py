from django.http import JsonResponse


def index(request):
    """Simple health check endpoint returning basic JSON.
    This provides a friendly response at the root URL ("/") instead of the default 404 page.
    """
    return JsonResponse({"status": "ok", "message": "Portal backend is running"})
