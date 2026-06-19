from django.contrib import admin
from .models import StudentProfile, TeacherProfile, ParentProfile, ParentStudentMapping

@admin.register(StudentProfile)
class StudentProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'enrollment_number', 'school', 'is_archived')
    search_fields = ('user__email', 'user__first_name', 'enrollment_number')
    list_filter = ('school', 'is_archived')

@admin.register(TeacherProfile)
class TeacherProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'employee_id', 'school', 'joining_date')
    search_fields = ('user__email', 'user__first_name', 'employee_id')
    list_filter = ('school',)

@admin.register(ParentProfile)
class ParentProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'phone_number', 'school')
    search_fields = ('user__email', 'user__first_name', 'phone_number')
    list_filter = ('school',)

@admin.register(ParentStudentMapping)
class ParentStudentMappingAdmin(admin.ModelAdmin):
    list_display = ('parent', 'student', 'relationship', 'is_primary_contact', 'school')
    search_fields = ('parent__user__email', 'student__user__email', 'student__enrollment_number')
    list_filter = ('school', 'relationship', 'is_primary_contact', 'can_view_academics', 'can_pay_fees')