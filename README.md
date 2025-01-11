# bgm-archive-sh

Some bash scripts to craw bgm topics.

## Usage

Check the `env_template.sh` for the environment variable setup.

First Copy the `env_template.sh` and rename it to `env.sh`. Fill the `E_BGM_ARCHIVE_GIT_REPO` env var. It should be path
to the git repository for crawled html files. You should initialize them in advance.

All commit message written by human beings should start with "META: " . For example:

```bash
$ mkdir bgm-archive-group-topic
$ cd bgm-archive-group-topic
$ git init
$ git commit --allow-empty -m "META: Initialize git repo."
```

If you want to log in to see some hidden topics, you may also need to provide the cookie and corresponding user-agent
string. Use this Chrome extension to help you get the curl compatible format cookie
file: [Get cookies.txt LOCALLY](https://chromewebstore.google.com/detail/cclelndahbckbenkjhflpdbgdldlbecc). For UA
string just visit `chrome://version/`, it's below the "Javascript: V8" line. Then you should be able to fill the
`E_BGM_COOKIE_FILE` and `E_BGM_UA` env vars. The UA string should be surrounded by single quotes.

Then you should be able to run the `general_job.sh` with one parameter (`blog`, `subject`, `character`, `person`,
`group` or `ep`). Each round of crawling will end with a git commit in the `E_BGM_ARCHIVE_GIT_REPO`. To run it
periodically just wrap it in a while true loop with proper sleeping.

To cope with [bgm-archive-kt](https://github.com/gyakkun/bgm-archive-kt), you can specify some webhook commands to run
after each batch of crawling. For webhook details please check the source code of `bgm-archive-kt`. Or you can just set
`git push` here to push to remote after every round of crawling.
