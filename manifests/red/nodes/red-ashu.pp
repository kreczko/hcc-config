node 'red-ashu.red.hcc.unl.edu' inherits red-private {

	$sshExtraAdmins = [ 'acaprez', 'jwang', 'dweitzel', 'bbockelm' ]
	$sudoExtraAdmins = [ 'acaprez', 'tharvill', 'jthiltge', 'jsamuels', 'jwang', 'dweitzel', 'bbockelm' ]

	$mountsHDFS = true

	include general

	include hadoop
   include ganglia

}

