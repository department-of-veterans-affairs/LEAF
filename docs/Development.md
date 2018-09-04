# Development

See the [README](standards/README.md) in the `standards` directory for information about coding standards.

## Branches

Major branches:

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
