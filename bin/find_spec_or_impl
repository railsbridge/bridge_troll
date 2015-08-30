#!/usr/bin/env ruby

filename = ARGV[0]
in_spec = filename =~ /_spec/
in_js = filename =~ /js$/

if in_js
  impl_prefix, spec_prefix, extension = "app/assets/javascripts/", "spec/javascripts/", ".js"
elsif filename =~ %r{^(lib|spec/lib)}
  impl_prefix, spec_prefix, extension = "lib/", "spec/lib/", ".rb"
else
  impl_prefix, spec_prefix, extension = "app/", "spec/", ".rb"
end

related_file = if in_spec
  filename.gsub(/^#{spec_prefix}/, impl_prefix).gsub(/_spec#{extension}$/, "#{extension}")
else
  filename.gsub(/^#{impl_prefix}/, spec_prefix).gsub(/#{extension}$/, "_spec#{extension}")
end

print related_file
