const fs = require("fs");
const path = require("path");

const files = [
  "src/pages/schoolAdmin/AcademicYears.jsx",
  "src/pages/schoolAdmin/AddMapping.jsx",
  "src/pages/schoolAdmin/AddParent.jsx",
  "src/pages/schoolAdmin/AddStudent.jsx",
  "src/pages/schoolAdmin/AddTeacher.jsx",
  "src/pages/schoolAdmin/AssignTeacher.jsx",
  "src/pages/schoolAdmin/ClassLevels.jsx",
  "src/pages/schoolAdmin/CreateAcademicYear.jsx",
  "src/pages/schoolAdmin/CreateRole.jsx",
  "src/pages/schoolAdmin/Dashboard.jsx",
  "src/pages/schoolAdmin/EditStudent.jsx",
  "src/pages/schoolAdmin/EditTeacherAssignment.jsx",
  "src/pages/schoolAdmin/MappingDetail.jsx",
  "src/pages/schoolAdmin/ParentDetail.jsx",
  "src/pages/schoolAdmin/ParentStudentMapping.jsx",
  "src/pages/schoolAdmin/Parents.jsx",
  "src/pages/schoolAdmin/RolesPermissions.jsx",
  "src/pages/schoolAdmin/StudentDetail.jsx",
  "src/pages/schoolAdmin/TeacherAssignment.jsx",
  "src/pages/schoolAdmin/TeacherDetail.jsx",
];

let fixedCount = 0;

files.forEach((filePath) => {
  const fullPath = path.join(process.cwd(), filePath);

  if (!fs.existsSync(fullPath)) {
    console.log(`⚠  Skipped (not found): ${filePath}`);
    return;
  }

  let content = fs.readFileSync(fullPath, "utf8");
  const original = content;

  // Case 1: const { darkMode } = useTheme();  → remove entire line
  content = content.replace(/^[ \t]*const\s*\{\s*darkMode\s*\}\s*=\s*useTheme\(\);[ \t]*\r?\n/gm, "");

  // Case 2: const { darkMode, X } = useTheme();  → const { X } = useTheme();
  content = content.replace(/const\s*\{\s*darkMode,\s*/g, "const { ");

  // Case 3: const { X, darkMode } = useTheme();  → const { X } = useTheme();
  content = content.replace(/,\s*darkMode(\s*)\}/g, "$1}");

  if (content !== original) {
    fs.writeFileSync(fullPath, content, "utf8");
    console.log(`✓  Fixed: ${filePath}`);
    fixedCount++;
  } else {
    console.log(`–  No change needed: ${filePath}`);
  }
});

console.log(`\nDone! Fixed ${fixedCount} file(s). All darkMode warnings should be gone.`);