from django.contrib import admin
from .models import AcademicYear, ClassLevel, Section, Subject, StudentEnrollment, TeacherAssignment

@admin.register(AcademicYear)
class AcademicYearAdmin(admin.ModelAdmin):
    list_display = ('name', 'school', 'start_date', 'end_date', 'is_active')
    list_filter = ('school', 'is_active')
    search_fields = ('name', 'school__name')

@admin.register(ClassLevel)
class ClassLevelAdmin(admin.ModelAdmin):
    list_display = ('name', 'numeric_order', 'school')
    list_filter = ('school',)
    search_fields = ('name', 'school__name')
    ordering = ('school', 'numeric_order')

@admin.register(Section)
class SectionAdmin(admin.ModelAdmin):
    list_display = ('name', 'class_level', 'school')
    list_filter = ('school', 'class_level')
    search_fields = ('name', 'class_level__name')

@admin.register(Subject)
class SubjectAdmin(admin.ModelAdmin):
    list_display = ('name', 'code', 'school')
    list_filter = ('school',)
    search_fields = ('name', 'code')
    filter_horizontal = ('class_levels',) 

# --- NEW ADMIN FOR TASK 3.2 ---
@admin.register(StudentEnrollment)
class StudentEnrollmentAdmin(admin.ModelAdmin):
    list_display = ('student', 'class_level', 'section', 'academic_year', 'roll_number', 'school')
    list_filter = ('school', 'academic_year', 'class_level')
    search_fields = ('student__user__first_name', 'student__user__email', 'roll_number')

@admin.register(TeacherAssignment)
class TeacherAssignmentAdmin(admin.ModelAdmin):
    list_display = ('teacher', 'subject', 'class_level', 'section', 'academic_year', 'is_class_teacher', 'school')
    list_filter = ('school', 'academic_year', 'is_class_teacher', 'class_level')
    search_fields = ('teacher__user__first_name', 'teacher__user__email', 'subject__name')