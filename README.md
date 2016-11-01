# README #

Code associated with developing a ptychography
and phase retrieval algorithm for a senior design project

### Contents ###

 * Code to generate mock ptychography data for testing
 * Ptychography and phase retrieval algorithm
 * Arduino C to control LED matrix
 * Interface with camera and arduino

### To Do: ###

 * Generate mock data
 * develop phase retrieval algorithm
 * ~~Control LED matrix~~
 * Add LED matrix control code to repository
 * Optimize Phase retrieval
 * Interface with camera
 * Interface with arduino

# Getting Started with Git #

Both [Atlassian](https://www.atlassian.com/git/tutorials/what-is-version-control) 
and [git](https://git-scm.com/book/en/v2) 
have fairly detailed reference materials available, 
and there are scores of other tutorials around the web.
Below is a highly-abridged guide.

### Install git ###

Go [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
to learn how to install git on whatever platform you're using.

Update your identity using
`git config --global user.name "John Doe"`
and `git config --global user.email johndoe@example.com`.
You may also wish to [specify a default editor](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup#Your-Editor).

### Clone the repository ###

Run `git clone https://robthereticent@bitbucket.org/robthereticent/ptychography.git`
to clone this repository into a new directory.
(This will create a directory called 'ptychography'
with this repository inside.)
This URL is shown at the top of the page.
See
[this guide](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository)
for more info.

### Make some Commits ###

There are four places a file can be: the working directory, the staging area,
the local repository, and the remote repository.

When making changes, only the working directory is modified.
These changes can then be staged for commit using `git add`.
The status of the staging area can be seen with `git status`,
and the exact changes made can be seen with `git diff` or `git diff --staged`.

Once changes have been staged, they can be committed to the local repository
with `git commit`.
**Be sure to specify a [good commit message](http://chris.beams.io/posts/git-commit/).**

### Push the changes ###

When some changes have been committed,
the remote repository should be updated with `git push`.
`git push origin master` may have to be run the first time
to specify which remote (origin) and which branch (master).
[details](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes)

If the remote repository has changed, `git push` will fail.
Use `git pull --rebase` (*not* `git pull`) to update the local repository
with changes from the remote.
After fixing any
[conflicts](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging#Basic-Merge-Conflicts),
run `git push` again as normal.

### History and Undoing things ###

Commit history can be viewed with `git log` or `git log --oneline`.
Which commits to show can be specified in a number of ways,
see [here](https://git-scm.com/docs/git-log) or `git help log`.

Commits can (should) only be changed in the local repository.
Commits that have been pushed to the remote repo
should not be changed to avoid conflicts.
See
[How to undo things](https://git-scm.com/book/en/v2/Git-Basics-Undoing-Things)
to learn how to undo things.
The difference between `reset` and `revert` can be somewhat mysterious.
[This](https://git-scm.com/2011/07/11/reset.html) or
[this](https://www.atlassian.com/git/tutorials/resetting-checking-out-and-reverting)
may help de-mystify.

### Going Further ###

 * [MATLAB Integration](http://blogs.mathworks.com/community/2014/10/20/matlab-and-git/)
 * [Set up SSH keys](https://confluence.atlassian.com/bitbucket/set-up-ssh-for-git-728138079.html)
 * [Learn about branching](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)
 * [Lots more tools](https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection)

## Command Reference ##

Command                     | Function
----------------------------|----------
`git status`                | Show the status of the repository
`git add <file>`            | Add `<file>` to the staging area
`git reset HEAD <file>`     | Remove `<file>` from the staging area
`git diff [--staged]`       | Show exactly what changes have been made
`git commit`                | Commit changes to the (local!) repository
`git rm <file>`             | Remove a file from repo and working directory
`git mv <file> <file_to>`   | Move or rename a file
`git log`                   | Show comit history
`git log -n --oneline`      | Show only last _n_ commits, one line each
`git pull --rebase`         | Fetch new changes from remote repository
`git push`                  | Push local commits to remote repository

See also `git help <command>` and 
[this cheat sheet](https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf). 