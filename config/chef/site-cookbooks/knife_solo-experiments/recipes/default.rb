execute 'apt-get update'

package "telnet"
package "postfix"
package "curl"
package "git-core"
package "zlib1g-dev"
package "libssl-dev"
package "libreadline-dev"
package "libyaml-dev"
package "libsqlite3-dev"
package "sqlite3"
package "libxml2-dev"
package "libxslt1-dev"
package "libpq-dev"
package "build-essential"
package "tree"

# set timezone
# bash "set timezone" do
#   code <<-EOH
#     echo 'US/Pacific-New' > /etc/timezone
#     dpkg-reconfigure -f noninteractive tzdata
#   EOH
#   not_if "date | grep -q 'PDT\|PST'"
# end
