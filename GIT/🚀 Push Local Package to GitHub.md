

Follow these steps to push your local Poetry-created Python package (e.g., `mypackage/`) to a new GitHub repository.

### 🔧 1. Create a GitHub Repository

- Go to: https://github.com/new
- Name the repo (e.g., `mypackage`)
- **DO NOT** initialize with a README, `.gitignore`, or license

After creation, GitHub will give you a URL like:
```
https://github.com/yourusername/mypackage.git
```

---

### 💻 2. Push Your Local Project to GitHub

Run the following commands in your local project directory:

```bash
cd mypackage

# Initialize git (if not already done)
git init

# Add all files and commit
git add .
git commit -m "Initial commit"

# Add the GitHub remote
git remote add origin https://github.com/yourusername/mypackage.git

# Set default branch to main and push
git branch -M main
git push -u origin main
```

---

✅ Your project is now live on GitHub!
- You can now track changes, collaborate, and set up CI/CD, docs, etc.
- Optionally add a GitHub Actions workflow or enable GitHub Pages for docs later.
