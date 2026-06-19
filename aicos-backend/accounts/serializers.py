from rest_framework import serializers
from .models import Role, UserRole, Permission
from tenants.models import User

class PermissionSerializer(serializers.ModelSerializer):
    """Read-only serializer to list available permissions."""
    class Meta:
        model = Permission
        fields = '__all__'

class RoleSerializer(serializers.ModelSerializer):
    # Accepts a list of Permission IDs on POST/PUT
    permissions = serializers.PrimaryKeyRelatedField(
        many=True, queryset=Permission.objects.all()
    )
    # Returns nested permission details on GET
    permission_details = PermissionSerializer(source='permissions', many=True, read_only=True)

    class Meta:
        model = Role
        fields = ['id', 'name', 'description', 'permissions', 'permission_details', 'school']
        read_only_fields = ['school', 'id']

class UserRoleSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source='user.email', read_only=True)
    role_name = serializers.CharField(source='role.name', read_only=True)

    class Meta:
        model = UserRole
        fields = ['id', 'user', 'role', 'user_email', 'role_name', 'school']
        read_only_fields = ['school', 'id']

    def validate(self, attrs):
        request = self.context.get('request')
        
        # Only validate on creation or update
        if not request or request.method not in ['POST', 'PUT', 'PATCH']:
            return attrs
            
        school = request.user.school
        user = attrs.get('user')
        role = attrs.get('role')

        # 1. STRICT ISOLATION: Ensure User belongs to the requester's school
        if user and user.school != school:
            raise serializers.ValidationError(
                {"user": "Security Exception: This user does not belong to your school."}
            )
        
        # 2. STRICT ISOLATION: Ensure Role belongs to the requester's school
        if role and role.school != school:
            raise serializers.ValidationError(
                {"role": "Security Exception: This role does not belong to your school."}
            )

        # 3. Prevent duplicate assignments (a user shouldn't have the 'Teacher' role assigned twice)
        if request.method == 'POST' and UserRole.objects.filter(school=school, user=user, role=role).exists():
            raise serializers.ValidationError(
                {"non_field_errors": ["This user already has this role assigned."]}
            )

        return attrs