# modules-tf

## Add Labels Permalink

You’ll need four labels for pull requests:

major
minor
patch
no-release

## Using the Module Permalink

To use a module in your Terraform template, you need to reference it in the following way:

module "module_reference_name" {
source = "git::https://github.com/{username_or_org_name}/{repo_name}.git?ref={module_name}/v{version}"
}

If you want to test your changes from a branch during development, you can do it this way:

module "app_configuration" {
source = "git::https://github.com/username_or_org_name/terraform-modules-monorepo-on-github.git//{repo_name}?ref=branch_name"
}
