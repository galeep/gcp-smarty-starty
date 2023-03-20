<p align="center">
  <img src="https://raw.githubusercontent.com/gale/gcp-smarty-starty/main/media/GCPSmartyStarty.png" alt="GCP Smarty Starty Logo" width="250" height="250">
</p>

<h1 align="center">GCP Smarty Starty</h1>
<p align="center">
  <i><Effortless GCP project setup for all skill levels.</i>
</p>

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
  - [Nice to have](#nice-to-have)
  - [Required](#required)
- [Usage](#usage)
- [Future Enhancements](#future-enhancements)
- [Usage Examples and Scenarios](#usage-examples-and-scenarios)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)
- [Rude FAQ](#rude-faq)

## Introduction

This script simplifies setting up a new Google Cloud Platform (GCP) project by automating the creation, configuration, and billing account linking process. Its purpose is to save time and effort for users who frequently create and manage GCP projects, particularly those with multiple side projects or experiments. The script encourages using GCP projects as safe, logical, and tidy boundaries, making tracking, analyzing, and managing resources easier.

## Features

- User-friendly and straightforward to use
- Generates a unique project ID with a customizable prefix
- Creates and configures the project with the given billing account
- Provides an option to perform a dry run without actually creating the project
- Supports non-interactive mode for automation purposes
- Allows the use of a custom dictionary file or a fallback dictionary for project ID generation

## Prerequisites

### Nice to have
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured with an active account. The script will attempt to download it if it cannot find `gcloud`, but that functionality is not well tested. 
- Basic familiarity with GCP terms and concepts

### Required
- GCP [Cloud Billing Account](https://cloud.google.com/billing/docs/how-to/manage-billing-account#create_a_new_billing_account) ID: A valid Cloud Billing account and billing account ID. 
- [Billing privileges](https://cloud.google.com/billing/docs/how-to/billing-access#overview_of_billing_roles_in): The ability to link Cloud Billing IDs with GCP projects.
- GCP: If you do not have a Google Cloud Platform account, you won't be able to do much with this tool. 

## Usage

Run the script with the desired options and follow the prompts to create a new GCP project. For a detailed explanation of the available options, run the script with the `--help` flag:

```
./gcp-smarty-starty.sh --help
```

## Future Enhancements

This tool has one job, and that's to create a project that is ready to be 
used for something else. A rule of thumb: if it needs to be done before 
`terraform apply` can be run, and it's normally driven by gcloud or 
things that puppet-string gcloud, then this script should be able to do it. Any configuration beyond that is a job for, well, `terraform`. :-) Please keep 
this perspective in mind as you consider this list of potential enhancements. 

1. Improve error handling and validation for user inputs and script execution.
2. Support modifying existing projects to apply new settings or configurations.
3. Add light support for additional GCP services and configurations, such as enabling APIs, setting up service accounts, and configuring IAM roles.
4. Integrate with GCP's Terraform export and import to aid the transition from proof of concept development to multidev/production.
5. Add support for organizing projects under folders and applying organization-wide policies.
6. Allow users to specify a list of enabled APIs and services during project creation.
7. Allow users to configure custom project templates with predefined settings and configurations.
8. Integration with the next step in the pipeline (Terraform, Ansible, kubectl, or whatever you needed this tool to get started with!) 
9. Logging
10. Rudimentary state management for projects and experiments (we're currently stateless, but if we bother with state, it should be shared.)

## Usage Examples and Scenarios
### Usage Examples and Scenarios - Table of Contents
- [Example 1: Basic Interactive Execution](#example-1-basic-interactive-execution)
- [Example 2: Non-Interactive Execution with Custom Prefix](#example-2-non-interactive-execution-with-custom-prefix)
- [Example 3: Dry Run with Custom Prefix and Billing Account](#example-3-dry-run-with-custom-prefix-and-billing-account)
- [Example 4: Custom Dictionary File for Project ID Generation](#example-4-custom-dictionary-file-for-project-id-generation)
- [Example 5: Quick Mode with Fallback Dictionary](#example-5-quick-mode-with-fallback-dictionary)
- [Example 6: User-Word Prefix Format](#example-6-user-word-prefix-format)

### Example 1: Basic Interactive Execution

To run the script in interactive mode, simply execute the script without any options:

```
./gcp-smarty-starty.sh
```

The script will prompt you to enter a prefix for the project ID and the billing account ID to use. Once provided, the script will create a new GCP project with a generated project ID and link the specified billing account.

### Example 2: Non-Interactive Execution with Custom Prefix

To create a new GCP project non-interactively with a custom prefix for the project ID, use the `-p` or `--prefix` option along with the `-y` or `--non-interactive` option:

```
./gcp-smarty-starty.sh --prefix "mycustomprefix" --non-interactive
```

The script will create a new GCP project with a generated project ID that starts with "mycustomprefix" and link the billing account associated with your active GCP account.

### Example 3: Dry Run with Custom Prefix and Billing Account

To perform a dry run without creating the project, use the `-n` or `--dry-run` option along with the `-p` or `--prefix` and `-b` or `--billing` options:

```
./gcp-smarty-starty.sh --prefix "mycustomprefix" --billing "012345-6789AB-CDEFGH" --dry-run
```

The script will generate a project ID with the specified prefix and display the billing account that would be linked, but it will not create the project or link the billing account.

### Example 4: Custom Dictionary File for Project ID Generation

To use a custom dictionary file for generating the project ID, use the `-w` or `--wordfile` option:

```
./gcp-smarty-starty.sh --wordfile "/path/to/your/dictionary.txt"
```

The script will use the words in the specified dictionary file to generate a project ID with a random word as part of the ID.

### Example 5: Quick Mode with Fallback Dictionary

To use the built-in fallback dictionary for project ID generation, use the `-q` or `--quick` option:

```
./gcp-smarty-starty.sh --quick
```

The script will use the fallback dictionary to generate a project ID with a random word as part of the ID, and it will not require access to the system's dictionary file.

### Example 6: User-Word Prefix Format

To generate a project ID with a prefix format that combines the current user's username and a random word, use the `-u` or `--user` option:

```
./gcp-smarty-starty.sh --user
```

The script will generate a project ID with the format "user-word-randomhex", where "user" is the current user's username, "word" is a random word, and "randomhex" is a random hexadecimal string.

## Contributing

We welcome contributions to this project! If you'd like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch with a descriptive name, such as `feature/new-feature` or `fix/issue-123`.
3. Make your changes in the new branch.
4. Submit a pull request (PR) to merge your branch into the main branch of the original repository.
5. Include a detailed description of your changes in the PR, and mention any issues or bugs that your changes are intended to address.

Before submitting a PR, please ensure that your code adheres to the project's coding style and conventions. Additionally, make sure to test your changes thoroughly to avoid introducing new bugs.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT). By contributing to this project or using the code, you agree to the terms and conditions of the MIT License. A copy of the license is available in the `LICENSE` file in the repository.

## Support

If you encounter any issues or have questions about this project, please open an issue on the [GitHub repository](https://github.com/galeep/gcp-smarty-starty/issues). We will do our best to help you and address any problems you may be experiencing.

When opening an issue, please provide as much information as possible about the problem, including the steps to reproduce the issue, the environment you're using, and any error messages you're encountering. This will help us diagnose and resolve the issue more quickly.

## Rude FAQ
### Rude FAQ - Table of Contents

- [Why should I use gcp-smarty-starty instead of just running a few commands?](#why-should-i-use-gcp-smarty-starty-instead-of-just-running-a-few-commands)
- [Why doesn't GCP just include, like, a `gcloud quickstart init`?](#why-doesnt-gcp-just-include-like-a-gcloud-quickstart-init)
- [Why not just use Google Cloud Project Factory?](#why-not-just-use-google-cloud-project-factory)
- [What if I want more control over project creation and configuration?](#what-if-i-want-more-control-over-project-creation-and-configuration)
- [Why did you choose to create the project ID using random words and a numeric string, just like the default GCP project naming scheme you're railing against? Isn't tracking projects with a unique ID enough?](#why-did-you-choose-to-create-the-project-id-using-random-words-and

### Why should I use gcp-smarty-starty instead of just running a few commands?

Sure, we're trying to avoid running three to five commands, and you might think gcp-smarty-starty is overkill. But here's the thing: people don't run those commands because they're annoying, and we're all lazy (including the author). What should be simple becomes a barrier, and that's not ideal.

In many environments, especially medium-sized groups of developers or researchers, projects are useful, but keeping track of them is hard. You know the drill – "Whose project was `quirky-beagle-37231`, and what was it for? Wait, Liz and Josh were both using it? For multiple things?" Laziness suddenly doesn't seem like such a virtue.

GCP often addresses these problems by doing things the "right way," but that's not always helpful for people who just want to get things done without spending half a day setting up private catalogs or whatever. Gcp-smarty-starty saves you time and energy, so you can focus on what you actually set out to do.

### Why doesn't GCP just include, like, a `gcloud quickstart init`?

We've been waiting for years for GCP to add a quickstart init to GCloud. If they have, then congrats to us for wasting a weekend writing a shell script! But the reality is that GCP hasn't made it easy to manage projects and make sense of the chaos, and we're left with solutions that look great in demos but don't work well in real life.

The way we see it, they forced our hand. So we created this script to help you avoid the frustration and get back to being productive. Enjoy the energy you'll gain from not having to deal with those same few commands over and over again.

### Why not just use Google Cloud Project Factory?

GCP Project Factory is a great tool for large organizations with specific requirements and policies. However, it requires extensive setup and specialized knowledge. Our script addresses an underserved middle ground – it's perfect for those who need a quick and easy tool to create and manage GCP projects without getting caught up in the complexities of a full-fledged Project Factory setup.

### What if I want more control over project creation and configuration?

This script provides a simple, user-friendly solution for creating GCP projects. If you need more control over project creation, configuration, or customization, you can always use the script as a starting point and modify it to suit your specific needs. With this script, you have a solid foundation to build upon for more advanced use cases. That said, this tool is what you run *prior* to Terraform, kubectl, etc. It's not a replacement for proper automation any more than BSD init is a replacement for systemd or launchd. Think of it like this: gcp-smarty-starty is the trusty old hoopty that gets you to the starting line, while Terraform, kubectl, and other automation tools are the high-performance race cars that take you through the actual race.

gcp-smarty-starty is designed to help you with the initial, slightly annoying setup process that usually stands between you and your actual work. It sets up a safe, logical, and organized environment for your projects, but it's not meant to handle the heavy-lifting of resource management and deployment. That's where your proper automation tools come into play.

So, use gcp-smarty-starty as a reliable jump-starter for your GCP projects, but don't rely on it to drive you all the way to the finish line. Remember, it's the hoopty that gets you started – but you'll still need your race car (i.e., Terraform, kubectl, etc.) to reach your destination.

### Why did you choose to create the project ID using random words and a numeric string, just like the default GCP project naming scheme you're railing against? Isn't tracking projects with a unique ID enough?

We recognize that GCP's default naming scheme has its limitations, but it serves as a starting point for us to improve upon. By using random words as part of the project ID, we create a "human-readable" identifier that provides a quick hint about the project's purpose or owner. This approach makes it much easier to manage multiple projects and keep track of their purpose, especially in larger organizations or when working with multiple side projects.  Our script enhances the naming scheme by allowing you to customize the prefix, use a custom dictionary file, or even follow a user-word format. These options give you more control over the project IDs, making them more meaningful and memorable, while still ensuring uniqueness.

The idea is to strike a balance between uniqueness and memorability. While GCP does assign a random identifier to the end of project IDs, it can still be challenging to keep track of numerous projects and understand their purpose at a glance. Incorporating random words into the project ID helps provide context, the hex string keeps names unique, but the real advantage the script provides is combining these with identifiers that are meaningful to you. 

Remember, the script is designed to help you work more efficiently and save time , but it's not set in stone. If you have specific requirements or preferences, feel free to modify the script or use it as a starting point for your custom solution. Happy coding!

### What's with the ridiculous name, gcp-smarty-starty?

It's absurd, and all the cool names were too close to trademarks. But, after much deliberation (and some swearing), we decided to embrace the ridiculousness and run with `gcp-smarty-starty`. Sometimes, you need a bit of absurdity to shake things up and make the mundane tasks more enjoyable. So, let gcp-smarty-starty brighten up your day while it takes care of your pesky project creation tasks!

### No, really. Why gcp-smarty-starty?

Well, we could've gone with a name that's more serious and "professional," but where's the fun in that? We wanted to create something that gets the job done and adds a touch of humor to it. Life's too short for boring project names, and we believe that a slightly snarky, quirky name like gcp-smarty-starty helps lighten the mood and makes the mundane tasks of project creation more enjoyable.

Besides, we're confident enough in the script's capabilities that we're willing to run with a name that might raise some eyebrows. Gcp-smarty-starty is here to challenge the notion that a tool has to sound serious to be effective. So, buckle up, and let gcp-smarty-starty bring some amusement to your GCP project management while still being a reliable and efficient helper!

### The name is too long/weird/hyphenated/hard to type/etc.

We know, we know – brevity is the soul of wit, eh? But at least the name is descriptive, unique, and absurdly amusing! Plus, it's a small price to pay for the convenience and time-saving benefits gcp-smarty-starty offers. And if you're really not a fan of the name, you can always give it a nickname or rename it to something shorter that suits your fancy. 
