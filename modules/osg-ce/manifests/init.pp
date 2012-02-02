#
# Class: osg-ce
#
class osg-ce {

	include osg-ce::params, osg-ce::install, osg-ce::config, osg-ce::service

	# must hard mount OSGAPP and OSGDATA to make RSV probes happy
	# automounting will not show correct permissions
	file { "/opt/osg": ensure => directory }
	file { "/opt/osg/app": ensure => directory, require => File["/opt/osg"], }
	mount { "/opt/osg/app":
		device  => "hcc-gridnfs:/osg/app",
		fstype  => "nfs4",
		ensure  => mounted,
		options => "rw,noatime,hard,intr,rsize=32768,wsize=32768",
		atboot  => true,
		require => File["/opt/osg/app"],
	}

	file { "/opt/osg/data": ensure => directory, require => File["/opt/osg"], }
	mount { "/opt/osg/data":
		device  => "hcc-gridnfs:/osg/data",
		fstype  => "nfs4",
		ensure  => mounted,
		options => "rw,noatime,hard,intr,rsize=32768,wsize=32768",
		atboot  => true,
		require => File["/opt/osg/data"],
	}

}
