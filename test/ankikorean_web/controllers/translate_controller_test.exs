defmodule AnkikoreanWeb.TranslateControllerTest do
  use AnkikoreanWeb.ConnCase

  test "GET /v1/translate", %{conn: conn} do
    conn = get conn, "/v1/translate", %{"email" => "test@example.com", "korean" => "안녕하세요"}
    assert json_response(conn, 200) == %{
             "success" => %{
               "data" => %{
                 "안녕하세요" => "1.Hello 2.Greeting 3.Hey"
               }
             }
           }
  end

  test "GET /v1/translate with no email", %{conn: conn} do
    conn = get conn, "/v1/translate", %{"email" => ""}
    assert json_response(conn, 422) == %{
             "error" => %{
               "message" => "Please make sure email and search field are filled in"
             }
           }
  end

  test "GET /v1/translate maintains state", %{conn: conn} do
    conn = get conn, "/v1/translate", %{"email" => "test-maintain-state@example.com", "korean" => "안녕하세요"}
    assert json_response(conn, 200) == %{
             "success" => %{
               "data" => %{
                 "안녕하세요" => "1.Hello 2.Greeting 3.Hey"
               }
             }
           }

    conn = get conn, "/v1/translate", %{"email" => "test-maintain-state@example.com", "korean" => "중국어"}
    assert json_response(conn, 200) == %{
             "success" => %{
               "data" => %{
                 "안녕하세요" => "1.Hello 2.Greeting 3.Hey",
                 "중국어" => "1.Hello 2.Greeting 3.Hey"
               }
             }
           }
  end

  test "GET /v1/translate stores the vocabulary list per email", %{conn: conn} do
    conn = get conn, "/v1/translate", %{"email" => "first@example.com", "korean" => "하나"}
    assert json_response(conn, 200) == %{
             "success" => %{
               "data" => %{
                 "하나" => "1.Hello 2.Greeting 3.Hey"
               }
             }
           }

    conn = get conn, "/v1/translate", %{"email" => "second@example.com", "korean" => "둘"}
    assert json_response(conn, 200) == %{
             "success" => %{
               "data" => %{
                 "둘" => "1.Hello 2.Greeting 3.Hey"
               }
             }
           }

  end

  test "DELETE /v1/translate", %{conn: conn} do
    Ankikorean.Cache.set("delete@example.com", %{"덕일" => "1.Germany", "네덜란드" => "1.Netherlands"})

    conn = delete conn, "/v1/translate", %{"email" => "delete@example.com", "korean" => "덕일"}
    assert json_response(conn, 200) == %{
             "success" => %{
               "data" => %{
                 "네덜란드" => "1.Netherlands"
               }
             }
           }

    assert {:found, %{"네덜란드" => "1.Netherlands"}} == Ankikorean.Cache.get("delete@example.com")
  end

  test "DELETE /v1/translate with no email", %{conn: conn} do
    conn = delete conn, "/v1/translate", %{"email" => ""}
    assert json_response(conn, 422) == %{
             "error" => %{
               "message" => "Please make sure email is filled in"
             }
           }
  end
end
