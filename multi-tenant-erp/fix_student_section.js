const fs = require('fs');
const path = require('path');

const erpSrc = 'c:/Users/biswa/OneDrive/Desktop/multi_tenent/multi-tenant-erp/src';
const oldSrc = 'c:/Users/biswa/OneDrive/Desktop/gshq/scholarflow-react/src';

// 1. Create missing directories
const uiDir = path.join(erpSrc, 'components/ui');
const sharedDir = path.join(erpSrc, 'components/shared');
if (!fs.existsSync(uiDir)) fs.mkdirSync(uiDir, { recursive: true });
if (!fs.existsSync(sharedDir)) fs.mkdirSync(sharedDir, { recursive: true });

// 2. Copy missing files
const filesToCopy = [
  { from: path.join(oldSrc, 'components/ui/Card.jsx'), to: path.join(uiDir, 'Card.jsx') },
  { from: path.join(oldSrc, 'components/shared/Sidebar.jsx'), to: path.join(sharedDir, 'Sidebar.jsx') },
  { from: path.join(oldSrc, 'components/shared/TopNavbar.jsx'), to: path.join(sharedDir, 'TopNavbar.jsx') }
];

filesToCopy.forEach(({ from, to }) => {
  if (fs.existsSync(from)) {
    fs.copyFileSync(from, to);
    console.log(`Copied ${path.basename(to)} to ${to}`);
  } else {
    console.log(`Warning: ${from} does not exist!`);
  }
});

// 3. Fix import paths in student pages
const studentPagesDir = path.join(erpSrc, 'pages/student');
const replaceInFiles = (dir) => {
  fs.readdirSync(dir).forEach(file => {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      replaceInFiles(fullPath);
    } else if (fullPath.endsWith('.jsx')) {
      let content = fs.readFileSync(fullPath, 'utf8');
      let changed = false;

      if (content.includes("import MainLayout from '../../layouts/MainLayout';")) {
        content = content.replace("import MainLayout from '../../layouts/MainLayout';", "import MainLayout from '../../../components/erp/student/MainLayout';");
        changed = true;
      }
      
      if (content.includes("import { Card } from '../../components/ui/Card';")) {
        content = content.replace("import { Card } from '../../components/ui/Card';", "import { Card } from '../../../components/ui/Card';");
        changed = true;
      }

      if (changed) {
        fs.writeFileSync(fullPath, content);
        console.log('Fixed imports in ' + fullPath);
      }
    }
  });
};

replaceInFiles(studentPagesDir);

// 4. Fix student layout component import paths
const mainLayoutPath = path.join(erpSrc, 'components/erp/student/MainLayout.jsx');
if (fs.existsSync(mainLayoutPath)) {
  let layoutContent = fs.readFileSync(mainLayoutPath, 'utf8');
  let layoutChanged = false;

  // The file imports from '../components/shared...', but MainLayout is in components/erp/student.
  // We need it to import from '../../shared/...'
  
  if (layoutContent.includes("import Sidebar from '../components/shared/Sidebar';")) {
    layoutContent = layoutContent.replace("import Sidebar from '../components/shared/Sidebar';", "import Sidebar from '../../shared/Sidebar';");
    layoutChanged = true;
  }
  if (layoutContent.includes("import TopNavbar from '../components/shared/TopNavbar';")) {
    layoutContent = layoutContent.replace("import TopNavbar from '../components/shared/TopNavbar';", "import TopNavbar from '../../shared/TopNavbar';");
    layoutChanged = true;
  }

  if (layoutChanged) {
    fs.writeFileSync(mainLayoutPath, layoutContent);
    console.log('Fixed imports in MainLayout.jsx');
  }
}
