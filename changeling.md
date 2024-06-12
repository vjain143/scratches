To automate the creation of a `CHANGELOG.md` file that captures the commits of a release branch, you can use a script. This script will generate a well-formatted Markdown file containing the commit history of the release branch compared to the main branch.

### Steps to Create an Automated Script for `CHANGELOG.md`

1. **Set Up Your Environment**:
   Ensure you have Git installed and that you are in the root directory of your repository.

2. **Create the Script**:
   Create a script that will fetch the commit history of the release branch and format it into a Markdown file.

Here is an example Bash script to achieve this:

```sh
#!/bin/bash

# Define the branches
BASE_BRANCH="main"
RELEASE_BRANCH="release"

# Define the output file
CHANGELOG_FILE="CHANGELOG.md"

# Header for the changelog
echo "# Changelog" > $CHANGELOG_FILE
echo "" >> $CHANGELOG_FILE

# Generate the changelog content
git log $BASE_BRANCH..$RELEASE_BRANCH --pretty=format:"- %h - %s (%an, %ad)" --date=short >> $CHANGELOG_FILE

echo "Changelog generated and saved to $CHANGELOG_FILE"
```

3. **Make the Script Executable**:
   Give execution permissions to the script.

```sh
chmod +x generate_changelog.sh
```

4. **Run the Script**:
   Execute the script to generate the `CHANGELOG.md`.

```sh
./generate_changelog.sh
```

### Example Content of `CHANGELOG.md`

When you run the script, it will generate a `CHANGELOG.md` file with content similar to the following:

```
# Changelog

- abc1234 - Fix bug in authentication (Alice, 2024-05-30)
- def5678 - Add new feature for user profile (Bob, 2024-05-29)
- ghi9012 - Improve performance of data processing (Carol, 2024-05-28)
```

### Customizing the Script

You can customize the `--pretty=format` option to include different information or to format it differently. Here are some common placeholders you can use:

- `%h`: Abbreviated commit hash
- `%s`: Subject of the commit
- `%an`: Author name
- `%ad`: Author date (format can be customized)
- `%d`: Refs (branches, tags)
- `%b`: Body of the commit

### Automating with Git Hooks

To ensure the `CHANGELOG.md` file is updated automatically with each merge into the release branch, you can integrate this script into a Git hook, such as `post-merge`. Here’s how you can set this up:

1. **Create the Hook**:
   Save the script as `.git/hooks/post-merge`:

```sh
#!/bin/bash

BASE_BRANCH="main"
RELEASE_BRANCH=$(git symbolic-ref --short HEAD)
CHANGELOG_FILE="CHANGELOG.md"

echo "# Changelog" > $CHANGELOG_FILE
echo "" >> $CHANGELOG_FILE
git log $BASE_BRANCH..$RELEASE_BRANCH --pretty=format:"- %h - %s (%an, %ad)" --date=short >> $CHANGELOG_FILE

echo "Changelog updated after merge"
```

2. **Make the Hook Executable**:
   Give execution permissions to the hook.

```sh
chmod +x .git/hooks/post-merge
```

### Summary

By following these steps, you can automate the creation and updating of a `CHANGELOG.md` file to capture the commits of a release branch. This ensures your changelog is always up-to-date with the latest changes and formatted consistently.
