/-  pokur,
    spider,
    zig=zig-ziggurat
/+  mip,
    strandio,
    ziggurat-system-threads=zig-ziggurat-system-threads,
    ziggurat-threads=zig-ziggurat-threads
/=  zig-configuration-zig-dev  /zig/configuration/zig-dev
::
=*  strand    strand:spider
=*  get-bowl  get-bowl:strandio
=*  scry      scry:strandio
::
=/  m  (strand ,vase)
=|  project-name=@t
=|  desk-name=@tas
=|  ship-to-address=(map @p @ux)
=*  zig-sys-threads
  ~(. ziggurat-system-threads project-name desk-name)
=*  zig-threads
  ~(. ziggurat-threads project-name desk-name ship-to-address)
|%
::
+$  arg-mold
  $:  project-name=@t
      desk-name=@tas
      request-id=(unit @t)
      repo-host=@p
      =long-operation-info:zig
  ==
::
++  make-repo-dependencies
  |=  =bowl:strand
  ^-  repo-dependencies:zig
  ::  REPLACE THIS ON DEPLOYMENT
  :+  [our.bowl %zig %master ~]
    [our.bowl %pokur %master ~]
  ~
::
++  make-config
  ^-  config:zig
  ~
::
++  make-virtualships-to-sync
  ^-  (list @p)
  ~[~nec ~bud ~wes]
::
++  make-install
  ^-  (map desk-name=@tas whos=(list @p))
  %-  ~(gas by *(map @tas (list @p)))
  :+  [%zig make-virtualships-to-sync]
    [%pokur make-virtualships-to-sync]
  ~
::
++  make-start-apps
  ^-  (map desk-name=@tas (list @tas))
  %-  ~(gas by *(map @tas (list @tas)))
  :_  ~
  [%zig ~[%subscriber]]
::
++  make-service-host
  ^-  @p
  ~nec
::
++  run-setup-project
  |=  $:  repo-host=@p
          request-id=(unit @t)
          =long-operation-info:zig
      ==
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  =bowl:strand  bind:m  get-bowl
  %:  setup-project:zig-sys-threads
      repo-host
      request-id
      (make-repo-dependencies bowl)
      make-config
      make-virtualships-to-sync
      make-install
      make-start-apps
      long-operation-info
  ==
::
++  setup-virtualship-state
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  state=state-1:zig  bind:m  get-state:zig-threads
  =*  configs  configs.state
  |^
  ;<  contract-hash=@ux  bind:m  setup-nec
  ;<  ~  bind:m  (setup-bud project-name contract-hash)
  ;<  ~  bind:m  setup-wes
  (pure:m !>(~))
  ::
  ++  setup-nec
    =/  m  (strand ,@ux)
    ^-  form:m
    =/  who=@p  ~nec
    ;<  contract-hash-vase=vase  bind:m
      %-  send-wallet-transaction:zig-threads
      :^  who  make-service-host
        !>(deploy-contract:zig-threads)
      [[%& who] make-town-id make-escrow-jam-path %.n ~]
    =+  !<(contract-hash=(unit @ux) contract-hash-vase)
    ?~  contract-hash  !!  ::  TODO
    ;<  empty-vase=vase  bind:m
      %-  send-discrete-pyro-poke:zig-threads
      :^  who  who  %pokur-host
      :-  %pokur-host-action
      !>  ^-  host-action:pokur
      :^  %host-info  who  (get-address who)
      [u.contract-hash make-town-id]
    ;<  ~  bind:m  (make-find-host who)
    ;<  ~  bind:m  (make-set-our-address who)
    (pure:m u.contract-hash)
  ::
  ++  setup-bud
    |=  [project-name=@t contract-hash=@ux]
    =/  m  (strand ,~)
    ^-  form:m
    =/  who=@p  ~bud
    ;<  ~  bind:m  (make-find-host who)
    ;<  ~  bind:m  (make-set-our-address who)
    ;<  empty-vase=vase  bind:m
      %-  send-wallet-transaction:zig-threads
      :^  who  make-service-host
        !>(send-discrete-pyro-poke:zig-threads)
      :^  who  who  %pokur
      :-  %pokur-player-action
      !>  ^-  player-action:pokur
      :*  %new-table
          *@da
          make-service-host
      ::
          :-  ~
          :^  `@ux`'zigs-metadata'  'ZIG'
          1.000.000.000.000.000.000  0x0
      ::
          2
          2
          [%sng 1.000 ~m60 ~[[1 2] [2 4] [4 8]] 0 %.n ~[100]]
          %.y
          %.y
          ~m10
      ==
    (pure:m ~)
  ::
  ++  setup-wes
    =/  m  (strand ,~)
    ^-  form:m
    =/  who=@p  ~wes
    ;<  ~  bind:m  (make-find-host who)
    ;<  ~  bind:m  (make-set-our-address who)
    (pure:m ~)
  ::
  ++  make-find-host
    |=  who=@p
    =/  m  (strand ,~)
    ^-  form:m
    ;<  empty-vase=vase  bind:m
      %-  send-discrete-pyro-poke:zig-threads
      :^  who  who  %pokur
      :-  %pokur-player-action
      !>  ^-  player-action:pokur
      [%find-host make-service-host]
    (pure:m ~)
  ::
  ++  make-set-our-address
    |=  who=@p
    =/  m  (strand ,~)
    ^-  form:m
    ;<  empty-vase=vase  bind:m
      %-  send-discrete-pyro-poke:zig-threads
      :^  who  who  %pokur
      :-  %pokur-player-action
      !>  ^-  player-action:pokur
      [%set-our-address (get-address who)]
    (pure:m ~)
  ::
  ++  make-town-id
    ^-  @ux
    0x0
  ::
  ++  service-host
    ^-  @p
    ~nec
  ::
  ++  make-escrow-jam-path
    ^-  path
    /con/compiled/escrow/jam
  ::
  ++  get-address
    |=  who=@p
    ^-  @ux
    (~(got by ship-to-address) who)
  --
::
++  $
  ^-  thread:spider
  |=  args-vase=vase
  ^-  form:m
  =/  args  !<((unit arg-mold) args-vase)
  ?~  args
    ~&  >>>  "Usage:"
    ~&  >>>  "-pokur-dev!ziggurat-configuration-pokur-dev project-name=@t desk-name=@tas request-id=(unit @t) repo-host=@p =long-operation-info:zig"
    (pure:m !>(~))
  =.  project-name         project-name.u.args
  =.  desk-name            desk-name.u.args
  =*  request-id           request-id.u.args
  =*  repo-host            repo-host.u.args
  =*  long-operation-info  long-operation-info.u.args
  ::
  ~&  %zcp^%top^%0
  ;<  =update:zig  bind:m
    %+  scry  update:zig
    /gx/ziggurat/get-ship-to-address-map/[project-name]/noun
  =.  ship-to-address
    ?>  ?=(^ update)
    ?>  ?=(%ship-to-address-map -.update)
    ?>  ?=(%& -.payload.update)
    p.payload.update
  ;<  setup-desk-result=vase  bind:m
    %^  run-setup-project  repo-host  request-id
    long-operation-info
  ~&  %zcp^%top^%1
  ;<  setup-ships-zigs-result=vase  bind:m
    setup-virtualship-state:zig-configuration-zig-dev
  ~&  %zcp^%top^%2
  ;<  setup-ships-pokur-result=vase  bind:m  setup-virtualship-state
  ~&  %zcp^%top^%3
  (pure:m !>(`(each ~ @t)`[%.y ~]))
--
