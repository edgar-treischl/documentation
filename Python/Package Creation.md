
# 🐍 Python Package Development Guide (Poetry + MkDocs + mkdocstrings)

## 1. 📦 Create a New Python Package
```bash
poetry new mypackage
cd mypackage
```

This creates the following structure:
```
mypackage/
├── pyproject.toml   # Package config
├── README.rst       # Project readme
├── mypackage/       # Source code
│   └── __init__.py
└── tests/           # Tests
```

---

## 2. 🛠️ Install the Project
```bash
poetry install
```

This installs dependencies and makes the package available for local importing:
```python
from mypackage import some_function
```

---

## 3. ➕ Add Dependencies
- Runtime dependency:
  ```bash
  poetry add requests
  ```
- Development dependency:
  ```bash
  poetry add --group dev pytest
  ```

---

## 4. 📝 Add Docstrings for Functions
```python
def greet(name: str) -> str:
    """
    Greet a person by name.

    Args:
        name (str): The person's name.

    Returns:
        str: A greeting message.
    """
    return f"Hello, {name}!"
```

---

## 5. 🌐 Create Documentation Website (like `pkgdown` in R)

### Option A: MkDocs + mkdocstrings (Recommended)

1. **Install Docs Dependencies**
   ```bash
   poetry add --group docs mkdocs mkdocstrings mkdocs-material
   ```

2. **Create Docs Folder**
   ```bash
   mkdir docs
   echo "# My Package" > docs/index.md
   echo "::: mypackage" > docs/api.md
   ```

3. **Create `mkdocs.yml`**
   ```yaml
   site_name: My Package Docs
   theme: material
   plugins:
     - mkdocstrings
   nav:
     - Home: index.md
     - API: api.md
   ```

4. **Preview Docs**
   ```bash
   mkdocs serve
   ```

   Visit: [http://127.0.0.1:8000](http://127.0.0.1:8000)

---

### Option B: Use pdoc (Simpler, standalone API docs)

> ⚠️ Use this if you’re okay with a separate, minimalistic API site.

1. **Install Compatible Version**
   ```bash
   poetry add --group docs "pdoc<15.0"  # For Python < 3.9
   ```

2. **Generate API Docs**
   ```bash
   pdoc --output-dir docs/api mypackage
   ```

3. **Link in MkDocs**
   Create `docs/api.md`:
   ```markdown
   # API Documentation

   - [View generated API docs](api/mypackage/greetings.html)
   ```

---

## ✅ Summary

| Tool            | Purpose                            | R Equivalent        |
|------------------|-------------------------------------|----------------------|
| Poetry           | Dependency/package management       | `usethis`, `devtools` |
| pytest           | Testing framework                   | `testthat`            |
| mkdocs + mkdocstrings | Docs + API docs in one site     | `pkgdown`             |
| pdoc (optional)  | Quick standalone API docs           | `roxygen2`-only style |

