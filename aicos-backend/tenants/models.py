import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser
from .managers import CustomUserManager

class School(models.Model):
    """
    Represents a Tenant in the multi-tenant architecture.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    subdomain = models.CharField(max_length=100, unique=True, db_index=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.subdomain})"

class TenantAwareModel(models.Model):
    """
    Abstract base class. Any model inheriting from this will strictly 
    belong to a specific school (Tenant).
    """
    school = models.ForeignKey(School, on_delete=models.CASCADE, related_name="%(app_label)s_%(class)s_set")

    class Meta:
        abstract = True

class User(AbstractUser):
    """
    Custom User model using UUIDs and Email for authentication.
    Notice it does NOT inherit from TenantAwareModel directly because 
    Global Admins (Superusers) might not belong to any single school.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = None  # Remove the username field entirely
    email = models.EmailField('email address', unique=True)
    
    # Nullable so Global Admins don't need a school, but regular users will.
    school = models.ForeignKey(
        School, 
        on_delete=models.CASCADE, 
        null=True, 
        blank=True, 
        related_name='users'
    )

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = [] # Email & Password are required by default

    objects = CustomUserManager()

    def has_perm(self, perm, obj=None):
        """
        BRIDGE: Routes Django Admin permission checks to our custom RBAC engine.
        """
        if self.is_superuser:
            return True
            
        # 1. Check standard Django permissions first
        if super().has_perm(perm, obj):
            return True
            
        # 2. Check our Custom UserRole mappings
        # Django Admin asks for permissions in this format: "app_label.action_modelname"
        # Example: "operations.view_attendance" or "operations.add_studentgrade"
        if self.school and hasattr(self, 'user_roles'):
            return self.user_roles.filter(
                school=self.school,
                role__permissions__codename=perm
            ).exists()
            
        return False

    def has_module_perms(self, app_label):
        """
        BRIDGE: Determines if the user can see the App module in the Admin sidebar.
        """
        if self.is_superuser:
            return True
            
        if super().has_module_perms(app_label):
            return True
            
        # If our custom RBAC grants ANY permission starting with the app_label, 
        # show the module in the Admin sidebar.
        if self.school and hasattr(self, 'user_roles'):
            return self.user_roles.filter(
                school=self.school,
                role__permissions__codename__startswith=f"{app_label}."
            ).exists()
            
        return False

    def __str__(self):
        return self.email