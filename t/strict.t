#!/usr/bin/perl
#
# Test Perl code for strict, warnings, syntax, and test coverage.
#
# Test coverage checking is disabled unless RRA_MAINTAINER_TESTS is set since
# it takes a long time, is sensitive to the versions of various libraries,
# and will not interfere with functionality.
#
# Copyright 2012 Russ Allbery <rra@stanford.edu>
#
# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

use strict;
use warnings;

use Test::More;

# Coverage level achieved.  We actually have 100% test coverage, but for some
# bizarre reason Devel::Cover reports only 70.5% condition coverage (while
# showing all conditions green in the HTML report).
use constant COVERAGE_LEVEL => 90;

# Skip tests if Test::Strict is not installed.
if (!eval { require Test::Strict }) {
    plan skip_all => 'Test::Strict required to test Perl syntax';
    $Test::Strict::TEST_WARNINGS       = 0;      # suppress warning
    $Test::Strict::DEVEL_COVER_OPTIONS = q{};    # suppress warning
}
Test::Strict->import;

# Test everything in the distribution directory.  We also want to check use
# warnings.
$Test::Strict::TEST_WARNINGS = 1;
all_perl_files_ok();

# Test code coverage.  Skip this test unless we're running the test suite in
# maintainer mode.
SKIP: {
    if (!$ENV{RRA_MAINTAINER_TESTS}) {
        skip 'Coverage test only run for maintainer', 1;
    }
    if (!eval { require Devel::Cover }) {
        skip 'Devel::Cover required to check test coverage', 1;
    }

    # Disable POD coverage; that's handled separately and is confused by our
    # autoloading.
    $Test::Strict::DEVEL_COVER_OPTIONS
      = '-coverage,statement,branch,condition,subroutine';
    all_cover_ok(COVERAGE_LEVEL);
}
