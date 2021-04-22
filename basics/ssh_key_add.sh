#!/bin/env bash
# mb insert in profile.d || .zshrc ?
ssh_path='/root/.ssh/work_git_key'
eval `ssh-agent -s`
ssh-add $ssh_path
ssh -T git@github.com