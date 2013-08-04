# This is a workaround for the lack of support for array, hash, boolean types
# for class parameters in the PE 3.0 console.
# This class wraps ntp, takes a comma-separted string of ntp servers, creates
# an array and passes this array as a parameter to the ntp class.
# It has future support for arrays in the console built in.
# This was designed for the following ntp module:
# name    'puppetlabs-ntp'
# version '1.0.1'

class console_ntp(
  # we want to be able to define the server list in the PE console
  $servers
) {
  # to future-proof this module for when PE Console supports array params
  if is_array($servers) {
    $servers_array = $servers
  # to work around lack of array param support by accepting a comma-separated string of servers
  } elsif is_string($servers) {
    if strip($servers) == '' {
      $servers_array = undef
    } else {
      $servers_array = split($servers, ',')
    }
  } else {
    fail("only array or string values are acceptable for servers parameter")
  }
  # if no valid server list, defer to defaults in ntp
  if $servers_array == undef {
    include ::ntp
  # otherwise validate, normalize, and pass our array of servers
  } else {
    # strip any whitespace from array elements to normalize
    $normal_servers_array = strip($servers_array)
    # deduplicate empty array entries
    $final_servers_array = delete($normal_servers_array, '')
    # make sure we ended up with a valid array
    validate_array($final_servers_array)
    #pass the array of ntp servers to ntp
    class { ::ntp:
      servers => $final_servers_array,
    }
  }
}
