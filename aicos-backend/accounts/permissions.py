from rest_framework import permissions

def HasModulePermission(module_name, action_type):
    """
    A Class Factory that dynamically generates a DRF Permission class.
    
    Usage in a ViewSet:
        permission_classes = [HasModulePermission('Attendance', 'write')]
        
    Args:
        module_name (str): The module being accessed (e.g., 'Attendance', 'Grades').
        action_type (str): The type of action (e.g., 'read', 'write', 'delete').
    """
    class _HasModulePermission(permissions.BasePermission):
        
        def has_permission(self, request, view):
            # 1. Unauthenticated users are immediately rejected
            if not request.user or not request.user.is_authenticated:
                return False

            # 2. Global Admins (Superusers) bypass all RBAC checks
            if request.user.is_superuser:
                return True

            # 3. Construct the codename we are looking for (e.g., 'attendance.write')
            required_codename = f"{module_name.lower()}.{action_type.lower()}"

            # 4. Check if the user has any role in their current school 
            #    that contains this specific permission codename.
            #    We use the `user_roles` related_name we defined in accounts/models.py
            has_permission = request.user.user_roles.filter(
                school=request.user.school,
                role__permissions__codename=required_codename
            ).exists()

            return has_permission
            
    # Return the generated class so DRF can instantiate it
    return _HasModulePermission