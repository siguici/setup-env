# 🚀 Setup Environment Action

A GitHub Action to install and configure essential tools on Linux, macOS, and Windows.

## 🧑‍💻 Usage

Add the following action to your GitHub workflow file (`.github/workflows/setup.yml`):

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: siguici/setup-env@v1
        with:
          packages: "curl wget git"
          upgrade: "true"
```

## 🛠️ Inputs

| Input      | Description                                  | Default      |
|------------|--------------------------------------------|--------------|
| `packages` | List of packages to install (space-separated) | `curl wget git` |
| `upgrade`  | Upgrade package managers before installation | `true`       |

## 🖥️ Supported Platforms

- ✅ **Ubuntu** (`apt`)
- ✅ **Fedora** (`dnf`)
- ✅ **Arch Linux** (`pacman`)
- ✅ **macOS** (`brew`)
- ✅ **Windows** (`choco`, `scoop`)

## 🏆 Why This Solution?

✅ **Extensible**: Easily add more package managers  
✅ **Customizable**: Users define their dependencies  
✅ **Secure**: OS detection, detailed logs, error handling  
✅ **Cross-Platform**: Linux, macOS, Windows  

## 📜 License

Under the [MIT License](./LICENSE.md).
Created with ❤️ by [Sigui Kessé Emmanuel](https://github.com/siguici).
