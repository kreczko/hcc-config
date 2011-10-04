#
# Class: condor
#
# Maintains condor configs
#
# does -not- restart/install, only config management for now
#
# TODO: split logic into separate sub classes (workers, submitters, collectors, etc...)
#
# FILE					exists on...
# -------------------------------
# 01-red					workers, submitters, collector
# 02-red-worker		workers
# 03-red-collector	collector
# 04-red-submitter	submitters
# 05-red-external		submitters, collector
# 06-htpc				<whole machine crap, so nowhere now>
# 09-thpc				THPC nodes
# 09-r410				KSU's r410 nodes (189-200)
# 09-node000			testing worker node (a vm)
#

class condor {

	include hostcert
	include hadoop

	package { condor: name => "condor.x86_64", ensure => installed }

	# NOTE: this ensure condor isn't set to run on reboot but does not necessiarly start it
   service { "condor":
      name => "condor",
      enable => false,
      hasrestart => true,
      hasstatus => true,
      require => [ Package["condor"], Class["hadoop"], Class["hostcert"], ],
   }


	# create condor_config.local if missing, but do not maintain it
	file { "/etc/condor/condor_config.local":
		owner   => "root", group => "root", mode => 644,
		ensure  => present,
		require => Package["condor"],
	}

	# clean config.d
	file { "/etc/condor/config.d":
		ensure => directory,
		owner   => "root", group => "root", mode => 0644,
		recurse => true,
		purge   => true,
		force   => true,
		require => Package["condor"],
	}


	# main condor config
	# exists on all nodes
	file { "/etc/condor/config.d/01-red":
		ensure  => present,
		owner   => "root", group => "root", mode => 644,
		source  => "puppet:///modules/condor/config.d/01-red",
		require => Package["condor"],
	}


	# exists on worker nodes
	if $isCondorWorker {
		file { "/etc/condor/config.d/02-red-worker":
			ensure => present,
			owner  => "root", group => "root", mode => 644,
			source => "puppet:///modules/condor/config.d/02-red-worker",
			require => Package["condor"],
		}

		# if a condorCustom09 class is defined, use it
		# this is for our custom START expressions like 09-thpc and 09-r410
		if $condorCustom09 {
			file { "/etc/condor/config.d/09-${condorCustom09}":
				ensure => present,
				owner  => "root", group => "root", mode => 644,
				source => "puppet:///modules/condor/config.d/09-${condorCustom09}",
				require => Package["condor"],
			}
		}
	}


	# exists on the collector(s)
	if $isCondorCollector {
		file { "/etc/condor/config.d/03-red-collector":
			ensure => present,
			owner  => "root", group => "root", mode => 644,
			source => "puppet:///modules/condor/config.d/03-red-collector",
			require => Package["condor"],
		}
	}


	# exists on submitters
	if $isCondorSubmitter {
		file { "/etc/condor/config.d/04-red-submitter":
			ensure => present,
			owner  => "root", group => "root", mode => 644,
			source => "puppet:///modules/condor/config.d/04-red-submitter",
			require => Package["condor"],
		}
	}


	# exists on collectors, submitters, and workers
	if $isCondorCollector or $isCondorSubmitter or $isCondorWorker {
		file { "/etc/condor/config.d/05-red-external":
			ensure => present,
			owner  => "root", group => "root", mode => 644,
			source => "puppet:///modules/condor/config.d/05-red-external",
			require => Package["condor"],
		}
	}


	# exists on collectors, submitters, and workers
	if $isCondorCollector or $isCondorSubmitter or $isCondorWorker {
		file { "/etc/condor/condor_mapfile":
			ensure => present,
			owner  => "root", group => "root", mode => 644,
			source => "puppet:///modules/condor/condor_mapfile",
			require => Package["condor"],
		}
	}



	# nfslite wrapper
	file { "/usr/local/bin/condor_nfslite_job_wrapper.sh":
		ensure => present,
		owner  => "root", group => "root", mode => 755,
		source => "puppet:///modules/condor/condor_nfslite_job_wrapper.sh",
		require => Package["condor"],
	}

	# srm-plugin
	file { "/usr/local/bin/srm-plugin":
		ensure => present,
		owner  => "root", group => "root", mode => 755,
		source => "puppet:///modules/condor/srm-plugin",
		require => Package["condor"],
	}

}

