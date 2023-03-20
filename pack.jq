($ARGS.named|with_entries(select(.key|test("^pack\\."))|.key|=sub("^pack\\.";"")|.value|=.[])) as $packs|
($ARGS.named|with_entries(select(.key|test("^trigger\\."))|.key|=sub("^trigger\\.";""))) as $triggers|
(
 ([(($ARGS.named|with_entries(select(.key|test("^triggerinfo\\."))|.key|=sub("^triggerinfo\\.";"")|.value|=.[]))|to_entries[]),
   ($packs[].triggers[]|{key:.name,value:.})
  ]|from_entries
 )
) as $triggerinfos|
($triggerinfos|keys|debug) as $dummy|
([$triggers,$triggerinfos]|map(keys[])|unique) as $triggerkeys|
{
  tables: [$packs[].tables[]],
  views: [$packs[].views[]],
  pages: [$packs[].pages[]],
  roles: [$packs[].roles[]],
  library: [$packs[].library[]],
  plugins: [$packs[].plugins[],
    (($ARGS.named.package? //
      [])[]|(.repository?.url? // ""
                ) as $repo|($repo|test("^git@github\\.com:")) as $isgithub|(if .name then {
      name: .name,
      description: .description?,
      source: (if $repo=="" then "npm" elif $isgithub then "github" else "git" end),
      location: (if $repo=="" then .name else ($repo|if $isgithub then sub("^git@github\\.com:";"") elif test("^https?://") then . else sub(":";"/")|sub("^git@";"https://") end) end),
      configuration: null,
      deploy_private_key: null
    } else empty end))],
  triggers: (
    $triggerkeys|map(. as $name|($triggerinfos[$name]? //
      {name: ., description: "auto-generated info", action: "run_js_code",
       when_trigger: "API call", channel: null, min_role: 1,
       configuration: {_: null, run_where: "Server", code: null}})|
      (if (.action=="run_js_code" or .action=="run_admin_js_code") and .configuration?.code?==null then
        (.name=$name|.configuration.code=$triggers[$name])
       else . end)
    )
  )
}
