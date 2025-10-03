# Development

See the [README](standards/README.md) in the `standards` directory for information about coding standards.

## Branches

Major branches:

### Master is the source of all truth 
  * All branches are off **Master**
  * All work branches spawned directly off (current setup)
  * When a branch is ready to be tested, a **Draft-PR** is made to **Master** 
  * When ready for branches to be moved into Production, a **Release Candidate (RC)** is spawned off **Master**. 
  * **RC is only merged to Master after release to Production**
  
### Moving from “Sprints” to “Cycles (of growth)”
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
  
### New Git-Flow
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

### HotFixes are put through a sped-up version of this flow.

### Automated Static Code Analysis
* Every push or PR triggers the SCA
* Go to the Actions tab and wait for completion.
  * Click on the run once it's finsihed.
  * Scroll down and you can download the various reports.  Start with "html-report.zip" to find what areas have issues.
* Currently, a "fail" will not stop progression. Majority of errors are due to the scope the script can view.


