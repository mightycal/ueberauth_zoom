ExUnit.start()

Mox.defmock(OAuthMock, for: [OAuth2.Strategy, Ueberauth.Strategy.Zoom.OAuthStrategy])
