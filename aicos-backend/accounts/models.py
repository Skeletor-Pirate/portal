import uuid
from django.db import models
from django.conf import settings
from tenants.models import TenantAwareModel

class Permission(models.Model):
    """
    Global system permissions. Not tenant-aware because these are hardcoded 
    features of the software (e.g., 'attendance.write', 'grades.read').
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100) # e.g., "Manage Attendance"
    codename = models.CharField(max_length=100, unique=True) # e.g., "attendance.write"
    module = models.CharField(max_length=50) # e.g., "Attendance", "Finance"

    def __str__(self):
        return f"{self.module} | {self.name}"

class Role(TenantAwareModel):
    """
    Dynamic roles created by School Admins. 
    Inherits from TenantAwareModel so roles don't leak across schools.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100) # e.g., "Class Teacher", "Accountant"
    description = models.TextField(blank=True)
    permissions = models.ManyToManyField(Permission, related_name='roles', blank=True)

    def __str__(self):
        return f"{self.name} ({self.school.name})"

class UserRole(TenantAwareModel):
    """
    Maps a User to a Role within a specific School.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='user_roles')
    role = models.ForeignKey(Role, on_delete=models.CASCADE, related_name='user_assignments')

    class Meta:
        # A user shouldn't have the exact same role twice in the same school
        unique_together = ('user', 'role')

    def __str__(self):
        return f"{self.user.email} - {self.role.name}"