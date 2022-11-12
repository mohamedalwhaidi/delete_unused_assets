The `delete_un_used_assets` package provides a concrete way of deleting assets using
Dart code.

- [Installation](#installation)
- [Usage](#usage)
  - [Built-in commands](#built-in-commands)

## Installation

Put it under [`dev_dependencies`], in your [`pubspec.yaml`].

```yaml
dev_dependencies:
    delete_un_used_assets: [latest-version]
```

## Usage
After running the command line at the bottom, it will search within the `assets` folder of your project
for any unused file within your project, then it will be deleted from this folder and moved to
a new folder `deleted_assets` in the root of your project with keeping track of deleted files.


### Built-in Commands

In your project root directory, run the following command:

```bash
flutter pub run delete_un_used_assets:start <assetsPath>
```

The available arg is `assetsPath`

- `assetsPath`: if you want to specify the path of the assets folder, you can do it by passing the path,
but the default value is `assets`.
