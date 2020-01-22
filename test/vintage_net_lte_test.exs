defmodule VintageNetLTETest do
  use ExUnit.Case

  alias VintageNet.Interface.RawConfig
  alias VintageNetLTE.ServiceProvider.Twilio

  test "create an LTE configuration" do
    priv_dir = Application.app_dir(:vintage_net_lte, "priv")
    input = %{type: VintageNetLTE}

    output = %RawConfig{
      ifname: "ppp0",
      type: VintageNetLTE,
      source_config: input,
      require_interface: false,
      up_cmds: [
        {:fun, VintageNetLTE, :run_usb_modeswitch, []},
        {:fun, VintageNetLTE, :run_mknod, []}
      ],
      files: [{"/tmp/vintage_net/twilio", Twilio.chatscript()}],
      child_specs: [
        {VintageNetLTE.SignalStrengthMonitor,
         [ifname: "ppp0", tty: "/dev/ttyUSB2", speed: 115_200]},
        {MuonTrap.Daemon,
         [
           "pppd",
           [
             "connect",
             "chat -v -f /tmp/vintage_net/twilio",
             "/dev/ttyUSB0",
             "115200",
             "noipdefault",
             "usepeerdns",
             "persist",
             "noauth",
             "nodetach",
             "debug"
           ],
           [env: [{"PRIV_DIR", priv_dir}, {"LD_PRELOAD", Path.join(priv_dir, "pppd_shim.so")}]]
         ]}
      ]
    }

    assert output == VintageNetLTE.to_raw_config("ppp0", input, Utils.default_opts())
  end
end
