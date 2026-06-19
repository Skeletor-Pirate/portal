from django.contrib import admin
from tenants.admin import TenantAwareModelAdmin
from .models import Role, UserRole, Permission

# 1. GLOBAL TABLE: Uses standard ModelAdmin
@admin.register(Permission)
class PermissionAdmin(admin.ModelAdmin):
    list_display = ('name', 'codename', 'module')
    list_filter = ('module',)
    search_fields = ('name', 'codename')

# 2. TENANT-AWARE TABLES: Uses strict TenantAwareModelAdmin
@admin.register(Role)
class RoleAdmin(TenantAwareModelAdmin):
    list_display = ('name', 'school', 'description')
    list_filter = ('school',) # Superusers will see this filter, School Admins only see their own
    search_fields = ('name',)
    filter_horizontal = ('permissions',) # <--- Added this to enable the Transfer UI

@admin.register(UserRole)
class UserRoleAdmin(TenantAwareModelAdmin):
    list_display = ('user', 'role', 'school')
    list_filter = ('school', 'role')
    search_fields = ('user__email', 'role__name')