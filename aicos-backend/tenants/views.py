from rest_framework import viewsets, generics
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied, ValidationError
from django.db.models.query import QuerySet
from django.contrib.auth import get_user_model
from drf_spectacular.utils import extend_schema, extend_schema_view
from .serializers import UserSerializer

User = get_user_model()

class TenantAwareModelViewSet(viewsets.ModelViewSet):
    """
    Base ViewSet that automatically filters all database queries by request.user.school.
    All future Module ViewSets (StudentProfileViewSet, AttendanceViewSet, InvoiceViewSet) 
    MUST inherit from this to guarantee strict data isolation across the SaaS.
    """
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Intercept the default DRF queryset and append the tenant filter dynamically.
        """
        assert self.queryset is not None, (
            "'%s' should either include a `queryset` attribute, "
            "or override the `get_queryset()` method."
            % self.__class__.__name__
        )

        queryset = self.queryset
        
        # FIX: Check against the actual Django QuerySet class
        if isinstance(queryset, QuerySet):
            queryset = queryset.all()

        user = self.request.user

        # Strict Isolation Rule: If the user belongs to a school, only return that school's data.
        if hasattr(user, 'school') and user.school:
            return queryset.filter(school=user.school)
            
        # Security Fallback: If a user somehow has no school assigned, 
        # return an empty queryset to prevent cross-tenant data leaks.
        return queryset.none()

    def perform_create(self, serializer):
        """
        Automatically inject the user's school into the created database row
        so the frontend doesn't have to manually pass a school_id in the payload.
        """
        user = self.request.user
        
        if not hasattr(user, 'school') or not user.school:
            raise PermissionDenied("You must be assigned to a school to create records.")
            
        # DYNAMIC ANTI-HIJACKING FIX: 
        # Iterate over all incoming relational fields (user, parent, student, etc.)
        # and ensure they belong to the admin's school.
        for field_name, value in serializer.validated_data.items():
            if hasattr(value, 'school') and value.school != user.school:
                raise ValidationError({field_name: f"This {field_name} does not belong to your school."})
            
        serializer.save(school=user.school)

    def perform_update(self, serializer):
        """
        Intercept updates to prevent maliciously re-assigning records to users 
        or objects from other schools.
        """
        user = self.request.user

        # DYNAMIC ANTI-HIJACKING FIX
        for field_name, value in serializer.validated_data.items():
            if hasattr(value, 'school') and value.school != user.school:
                raise ValidationError({field_name: f"This {field_name} does not belong to your school."})

        serializer.save(school=user.school)


class CurrentUserView(generics.RetrieveAPIView):
    """
    GET /auth/me/
    Returns the currently authenticated user's details based on their JWT.
    """
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user

# --- NEW USER CRUD ENDPOINTS ---

@extend_schema_view(
    list=extend_schema(summary="List all users in the school"),
    create=extend_schema(summary="Create a new user"),
    retrieve=extend_schema(summary="Retrieve user details"),
    update=extend_schema(summary="Update a user"),
    partial_update=extend_schema(summary="Partially update a user"),
    destroy=extend_schema(summary="Delete a user"),
)
class UserViewSet(TenantAwareModelViewSet):
    """
    CRUD endpoints for Tenant Users. 
    Automatically isolated to the requester's school.
    """
    queryset = User.objects.select_related('school').all()
    serializer_class = UserSerializer