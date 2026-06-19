from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    StudentProfileViewSet, TeacherProfileViewSet, 
    ParentProfileViewSet, ParentStudentMappingViewSet,
    UserContextView
)

router = DefaultRouter()
router.register(r'students', StudentProfileViewSet, basename='student')
router.register(r'teachers', TeacherProfileViewSet, basename='teacher')
router.register(r'parents', ParentProfileViewSet, basename='parent')
router.register(r'parent-student-mappings', ParentStudentMappingViewSet, basename='parent-student-mapping')

urlpatterns = [
    # Task 2.4: Context Switching Endpoint
    path('me/', UserContextView.as_view(), name='user-context'),
    
    # Task 2.3: Profile ViewSets Endpoints
    path('', include(router.urls)),
]