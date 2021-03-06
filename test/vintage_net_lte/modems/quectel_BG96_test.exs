defmodule VintageNetLTE.Modems.QuectelBG96Test do
  use ExUnit.Case

  alias VintageNetLTE.Modems.QuectelBG96

  test "returns correct spec" do
    provider_info = %{apn: "test.apn.com"}

    assert %{
             serial_port: "ttyUSB3",
             serial_speed: 9600,
             chatscript: chatscript(),
             command_port: "ttyUSB2"
           } ==
             QuectelBG96.spec(provider_info)
  end

  defp chatscript() do
    """
    # Exit execution if module receives any of the following strings:
    ABORT 'BUSY'
    ABORT 'NO CARRIER'
    ABORT 'NO DIALTONE'
    ABORT 'NO DIAL TONE'
    ABORT 'NO ANSWER'
    ABORT 'DELAYED'
    TIMEOUT 10
    REPORT CONNECT

    # Module will send the string AT regardless of the string it receives
    "" AT

    # Instructs the modem to disconnect from the line, terminating any call in progress. All of the functions of the command shall be completed before the modem returns a result code.
    OK ATH

    # Instructs the modem to set all parameters to the factory defaults.
    OK ATZ

    # Result codes are sent to the Data Terminal Equipment (DTE).
    OK ATQ0

    # Define PDP context
    OK AT+CGDCONT=1,"IP","test.apn.com"

    # ATDT = Attention Dial Tone
    OK ATDT*99***1#

    # Don't send any more strings when it receives the string CONNECT. Module considers the data links as having been set up.
    CONNECT ''

    """
  end
end
