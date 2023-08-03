"use strict";

const { Octokit } = require('@octokit/rest')
const archiver = require('archiver')
const fs = require('fs')
const semver = require('semver')

class GitHub {
  constructor({ owner, repo, token }) {
    this.bundleFileBasename = 'MuleSoft.zip'
    this.owner = owner
    this.repo = repo
    this.octokit = new Octokit({ auth: `token ${token}` })
  }

  async createZipFile (path) {
    const output = fs.createWriteStream('MuleSoft.zip')
    const archive = archiver('zip', { zlib: { level: 9 } })

    archive.pipe(output)
    archive.directory(path, false)
    archive.finalize()
  }

  async getLatestReleaseVersion () {
    const { data: releases } = await this.octokit.rest.repos.listReleases({
        owner: this.owner,
        repo: this.repo,
        per_page: 5,
        page: 1,
    })
    return releases[0].tag_name
  }

  async getLastPRLink () {
    const { data: pulls } = await this.octokit.rest.pulls.list({
      owner: this.owner,
      repo: this.repo,
      state: 'closed',
      per_page: 1,
    })

    if (pulls) {
      return pulls[0].html_url
    }
  }

  async setBranchName () {
    let branchName = process.env.GIT_BRANCH || 'master'
    if (branchName.startsWith('origin/')) {
      branchName = this.branchName.substring(7)
    }

    return branchName
  }

  async setTagName () {
    const latestVersion = await this.getLatestReleaseVersion()
    return `v${semver.inc(latestVersion, 'major')}`
  }

  async setUp () {
    this.branchName = await this.setBranchName()
    this.ref = `heads/${this.branchName}`
    this.tagName = await this.setTagName()

    console.log(`
    Set up completed with the following variables:
      branch name: ${this.branchName}
      ref: ${this.ref}
      tag name: ${this.tagName}
    `)
  }

  async release() {
    await this.setUp()
    console.log(`Creating the next release ${this.tagName}...`)
    await this.createZipFile('MuleSoft')

    let commit = await this.octokit.git
      .getRef({
        owner: this.owner,
        repo: this.repo,
        ref: this.ref,
      })
      .then((result) => result.data.object.sha)

    this.release = await this.octokit.repos
      .createRelease({
        owner: this.owner,
        repo: this.repo,
        tag_name: this.tagName,
        target_commitish: commit,
        name: this.tagName,
        body: `A new release of Vale rules is here! Please see https://confluence.internal.salesforce.com/display/MTDT/Vale+Automatic+Style+Checker#ValeAutomaticStyleChecker-UsingVale for instructions on how to update your rules on your computer.
        Open ${await this.getLastPRLink()} to see what has changed with this release.`,
      })
      .then((result) => result.data)

    await this.octokit.repos.uploadReleaseAsset({
      url: this.release.upload_url,
      data: fs.createReadStream(this.bundleFileBasename),
      name: this.bundleFileBasename,
      headers: {
        'content-length': fs.statSync(this.bundleFileBasename).size,
        'content-type': 'application/zip',
      },
    })

    console.log(`Successfully created release ${this.tagName}.`)
  }
}


const gitHub = new GitHub({
  owner: "mulesoft",
  repo: "mulesoft-docs-writing-style",
  token: process.env.GH_TOKEN,
})

gitHub.release()
