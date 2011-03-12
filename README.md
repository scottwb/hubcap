Development Setup
=================

  * Make sure you have RVM installed.
  * Make sure you have ruby-1.9.2-p180 installed via RVM.
  * The first time you cd into this directory, you may be prompted to trust
    the .rvmrc file. Say 'yes'.
  * The first time, this will create the necessary gemset and install gems.
  * Any other time you cd into this directory, it will check to see if there
    are any other gems that need to be installed (via bundler).
  * Installed gems are only installed to the rvm environment specific to this
    app.

Troubleshooting
---------------

  * The first time cd-ing into this directory checks for bundler, you may have
    issues with an existing bundler installed in your ~/.gem directory. If that
    is the case, simply remove that directory's bin dir from your $PATH and
    cd out and back into this directory.

