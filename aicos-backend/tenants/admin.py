from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from .models import School, User

class TenantAwareModelAdmin(admin.ModelAdmin):
    """
    Base Admin class to ensure non-superusers (like Teachers) 
    only see their own school's data in the Django Admin panel.
    """
    def get_queryset(self, request):
        qs = super().get_queryset(request)
        if request.user.is_superuser:
            return qs
        if request.user.school:
            return qs.filter(school=request.user.school)
        return qs.none()

    def save_model(self, request, obj, form, change):
        # Auto-assign the teacher's school to the object being created
        if not change and hasattr(obj, 'school') and getattr(obj, 'school', None) is None:
            if request.user.school:
                obj.school = request.user.school
        super().save_model(request, obj, form, change)

class CustomUserCreationForm(UserCreationForm):
    class Meta:
        model = User
        fields = ('email', 'school')

class CustomUserChangeForm(UserChangeForm):
    class Meta:
        model = User
        fields = ('email', 'school')

@admin.register(School)
class SchoolAdmin(admin.ModelAdmin):
    list_display = ('name', 'subdomain', 'is_active', 'created_at')
    search_fields = ('name', 'subdomain')
    list_filter = ('is_active',)

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    add_form = CustomUserCreationForm
    form = CustomUserChangeForm

    # We must override fieldsets since we removed the 'username' field
    ordering = ('email',)
    list_display = ('email', 'first_name', 'last_name', 'school', 'is_staff')
    search_fields = ('email', 'first_name', 'last_name')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'school')
    
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'school')}),
        ('Permissions', {
            'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions'),
        }),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )

    # Override the layout for the "Add User" page
    # Must use password1 and password2 as they are explicitly named in UserCreationForm
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'school', 'password1', 'password2'),
        }),
    )