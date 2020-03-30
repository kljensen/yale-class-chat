defmodule YaleLDAP do

  @moduledoc """
  Functions for interacting with the Yale's LDAP directory
  """

  def get_attrs_by_netid(net_id) do
    case LDAPEx.Client.start_link() do
      {:ok, ldap} ->
        req = LDAPEx.Client.setup_search(baseObject: "OU=Users-OU,DC=yu,DC=yale,DC=edu", filter: {:and, [{:equalityMatch, {:AttributeValueAssertion, "objectclass", "person"}}, {:equalityMatch, {:AttributeValueAssertion, "cn", net_id}}]} )
        case LDAPEx.Client.search(ldap, req) do
          {:ok, {[], []}} ->
            _ = LDAPEx.Client.close(ldap)
            {:error, "No results from LDAP server"}

          {:ok, {res, _references}} ->
            _ = LDAPEx.Client.close(ldap)
            [r] = res
            is_faculty = Enum.member?(r.attributes["memberOf"], "CN=All_Faculty,OU=General Access,OU=Applications,OU=Enterprise Systems,OU=Information Technology Services,DC=yu,DC=yale,DC=edu")
            {:ok, %{display_name: List.first(r.attributes["givenName"]) <> " " <> List.first(r.attributes["sn"]), email: List.first(r.attributes["mail"]), is_faculty: is_faculty}}
          _ ->
            _ = LDAPEx.Client.close(ldap)
            {:error, "Invalid result from LDAP server"}
        end
      _ ->
        {:error, "Unable to connect to LDAP server"}
    end
  end
end
