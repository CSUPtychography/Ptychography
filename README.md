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

All of the commands below can be entered on the windows command line, or in git bash.
They can also be used in matlab if preceded by `!`.

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
Try to make 
[atomic commits](https://seesparkbox.com/foundry/atomic_commits_with_git)
as much as possible. 
It is possible to commit only some changes in a file using `git add -p`
if the changes are unrelated. 
See the link on atomic commits above for details. 

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

### Branches ###

It is generally good practice to keep unrelated features on different branches
to avoid conflicts and allow for parallel feature development.
A branch can be created using `git branch <branch name>`.
To switch to a branch use `git checkout <branch>`.
The 'main' or default branch is called `master`.
A list of all branches and the current branch can be seen with `git branch`.
To push a branch's commits to a remote repository, use `git push <branch>`
Right after a branch has been created, `git push -u origin <branch>` must be used
to create a branch in the remote repo, and set the upstream reference.
[More info here](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging).

Once a branch's feature has been completed, and is ready for publishing,
it must be merged into the master branch.
This is done by checking out the master branch
(or whatever branch the feature should be merged into),
and running `git merge <branch>`.
If conflicts are present they must be resolved, and a commit message specified.
A new commit will be created on the current branch.
[Here is some information on resolving conflicts](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging#Basic-Merge-Conflicts).

### Going Further ###

 * [MATLAB Integration](http://blogs.mathworks.com/community/2014/10/20/matlab-and-git/)
 * [Set up SSH keys](https://confluence.atlassian.com/bitbucket/set-up-ssh-for-git-728138079.html)
 * [Learn about branching](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)
 * [Lots more tools](https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection)

## Command Reference ##

These commands can be used in the matlab command line by preceding them with `!`.
(e.g. `!git diff`)

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
`git branch <branch>`       | Create a new branch called `<branch>`
`git checkout <branch>`     | Switch to another branch
`git checkout -b <branch>`  | Create a new branch and switch to it
`git merge <branch>`        | Merge `<branch>` into the current branch
`git push <branch>`         | Push and update tracking information

See also `git help <command>` and
[this cheat sheet](https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf).
