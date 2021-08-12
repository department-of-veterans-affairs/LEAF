# Development

See the [README](standards/README.md) in the `standards` directory for information about coding standards.

## Branches

Major branches:

###Master is the source of all truth 
  * All branches are off **Master**
  * All work branches spawned directly off (current setup)
  * When a branch is ready to be tested, a **Draft-PR** is made to **Master** 
  * When ready for branches to be moved into Production, a **Release Candidate (RC)** is spawned off **Master**. 
  * **RC is only merged to Master after release to Production**
  
###Moving from “Sprints” to “Cycles (of growth)”
* Tickets are still broken down into **“1 week work” chunks** 
  * “Sprint” infers that tickets need to be completed in a set span of time
  * Induces a rush to get tickets done
  * Pressure to release “good enough” vs “good”
  * Adds a bad level of competition between developers (I got this many done this sprint!)
* **“Cycle”** 
  * There is still a push to get them loaded onto the “next” release, but much less “do or die”.
  * Pushes the iterative mindset 
  * Picking up the speed of deployments 
  * Nothing can get “held back” just because one of the tickets needed more work after feedback.
  
###New Git-Flow
* Developers get/choose the tickets to work and spawn their working branch 
* Once ready, **Draft-PR to Master**
* All branch-specific and regression testing is done then.
* **Friday**
  * **Release Candidate is spawned from Master**
  * All working-branches that are ready are merged near end of day. 
  * Final QA testing is done on the “push” branch.  (Should be mostly automated)
* **Monday** (assuming code has passed all tests)
  * RC is demoed to Michael Gao and Crystal. 
  * If any aren’t given immediate go-ahead, they are pulled from the RC 
  * By “pulled” it is meant the RC is killed, a new one created, and the approved work branches are merged to the new RC.
  * **RC is pushed to PreProd** for anyone to test and get ready for Push-to-Prod
* **Thursday**
  * Unless there are last minute issues, **RC is put on Production**. 
* **Tuesday** 
  * **If there were no issues, RC is merged to Master** 
  * If there are issues, it is evaluated if they should be treated as an additional “BugFix” or needing full roll-back. 
  * If BugFix, RC is merged to Master and new BugFix branch is spawned from Master and moved into the normal cycle. 
  * **If full roll-back is required, Master is Pushed to Prod and the RC abandoned.**
* **Wednesday**
  * Hold my beer 

###HotFixes are put through a sped-up version of this flow.

* This is a work-in-evolution





* `master`: Contains the production ready code.
  * **NEVER** commit into `master`. **ONLY** pull requests from the `dev` branch and urgent hotfixes can be merged into `master`.
* `dev`: Contains finished code from the current sprint, ready for merging into `master` at any time.
  * **NEVER** commit into `dev`, create a pull request.

Typical workflow:

1. Start with the `dev` branch. Ensure `dev` is up to date on your machine.
1. Create a new feature branch from `dev` with the format `leaf###_short_feature_description`
    * Each branch name should begin with lowercase `leaf###` where `###` is the issue/ticket number and end with a short description of the feature. 
    * **NOTE:** Branch naming consistency is important in order to quickly determine what each branch is for. Do not deviate from the pattern mentioned above without a good reason.
1. Write code. Ensure proper tests are created (where applicable) and all existing tests pass.
1. Rebase the feature branch into as few logical commits as possible (1-3 total commits is ideal). 
1. Create a [good commit message](https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message). Keep the commit subject under 50 characters, and wrap the commit message body at 72 characters.
1. Push feature branch to remote origin.
1. Create a pull for the feature branch into `dev`. The request name should follow the format: "LEAF<ticket#> Short Description"
1. Teammates will comment on and/or approve the changes (see [CodeReviews](CodeReviews.md).
1. Make any necessary changes. 
1. Push changed feature branch to remote.
1. The pull request from the feature branch will be automatically updated.
1. After the pull request has been reviewed, approved, and merged, the feature branch will be deleted.
