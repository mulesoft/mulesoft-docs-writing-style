# MuleSoft Developer Documentations Writing Style

This repository contains a [Vale-compatible](https://github.com/errata-ai/vale) implementation of the MuleSoft Writing Style Guide, which is loosely based on the [Microsoft Writing Style Guide](https://docs.microsoft.com/en-us/style-guide/welcome/). 
[LICENSE](LICENSE)

The primary purpose of this repository is to enforce the writing style of the [MuleSoft Technical Documentation](https://docs.mulesoft.com). It contains the style rules in the form of a series of yaml files, which are used by Vale to automatically lint the documentation content via Github actions.

## Getting Started

### Onboarding Local Vale Runs (For Salesforce Employees Only)

See [The Download Onboarding Script section](https://confluence.internal.salesforce.com/pages/viewpage.action?spaceKey=MTDT&title=Set+Up+Your+Build+Environment#SetUpYourBuildEnvironment-DownloadOnboardingScript)

## Test

Run `make test` to test the rules against the files in the **test-files/** directory. Run `make test-debug` to see the vale output.

Another way to test is to copy and compile your rule in [Vale Studio](https://studio.vale.sh/), and then run it against your test cases.

### How to Test New Rules

If you have created a new rule, please add an adoc file full of test phrases with the same name in **test-files/**. Then add an entry for it in [violation-count-map.yaml](test-files/violation-count-map.yaml).

## Resources

* [MuleSoft Writing Style Guide (internal resource. VPN required)](https://confluence.internal.salesforce.com/display/MTDT/MuleSoft+CX+Writing+Style+Reference)
* [errata-ai's repo. Good for referencing rules from other styles](https://github.com/errata-ai)
* [vale documentation](https://vale.sh/)
* [Vale Studio. Good for testing rules in a web browser](https://studio.vale.sh/)
