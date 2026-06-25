from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView
from .views import index
from tutor import ai_generators as tutor_ai

urlpatterns = [
    path('', index),
    path('admin/', admin.site.urls),
    
    # API Routes Base
    path('api/v1/', include('tenants.urls')),
    path('api/v1/profiles/', include('profiles.urls')),
    path('api/v1/academics/', include('academics.urls')),
    path('api/v1/operations/', include('operations.urls')),
    path('api/v1/accounts/', include('accounts.urls')),
    
    # YOUR ISOLATED ADMIN ROUTE LAYER
    path('api/v1/school-admin/', include('school_admin.urls')),
    
    # AI TUTOR MODULE
    path('api/v1/tutor/', include('tutor.urls')),
    
    # TOP-LEVEL AI ENDPOINTS (Matching ERP Structure)
    path('api/v1/generate_lesson_plan/', tutor_ai.generate_lesson_plan),
    path('api/v1/generate_worksheet/', tutor_ai.generate_worksheet),
    path('api/v1/evaluate_worksheet/', tutor_ai.evaluate_worksheet),
    path('api/v1/generate_quiz/', tutor_ai.generate_quiz),
    path('api/v1/generate_question_paper/', tutor_ai.generate_question_paper),
    path('api/v1/generate_study_notes/', tutor_ai.generate_study_notes),
    path('api/v1/generate_presentation_outline/', tutor_ai.generate_presentation_outline),
    path('api/v1/generate_rubric/', tutor_ai.generate_rubric),
    
    # Swagger / OpenAPI Endpoints (Restored!)
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]