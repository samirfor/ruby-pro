package app;

import java.io.BufferedReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.Reader;
import org.lobobrowser.html.HtmlRendererContext;
import org.lobobrowser.html.UserAgentContext;
import org.lobobrowser.html.gui.HtmlPanel;
import org.lobobrowser.html.parser.DocumentBuilderImpl;
import org.lobobrowser.html.parser.InputSourceImpl;
import org.w3c.dom.Document;
import org.w3c.dom.html2.HTMLElement;
import org.xml.sax.InputSource;
import org.lobobrowser.html.test.*;
import org.xml.sax.SAXException;

/**
 *
 * @author samir
 */
public class BrowserSilencioso {

    private String uri;
    private String body;
    private String login;
    private String senha;
    private String ip;

    public BrowserSilencioso(String ip, String login, String senha) {
        uri = "http://" + ip + "/login";
        this.login = login;
        this.senha = senha;
        this.ip = ip;
    }

    public String convertStreamToString(InputStream is) throws IOException {
        /*
         * To convert the InputStream to String we use the BufferedReader.readLine()
         * method. We iterate until the BufferedReader return null which means
         * there's no more data to read. Each line will appended to a StringBuilder
         * and returned as String.
         */
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();

        String line = null;

        while ((line = reader.readLine()) != null) {
            sb.append(line + "\n");
        }
        is.close();

        return sb.toString();
    }

    public void open() throws MalformedURLException, IOException, SAXException {
        // Open a connection on the URL we want to render first.
        URL url = new URL(uri);
        URLConnection connection = url.openConnection();
        InputStream in = connection.getInputStream();

        // Read body from InputStream
        body = convertStreamToString(in);
        body = body.replace("<head>", "<head><base href=\"http://" + ip + "\">");
        body = body.replace(
                "document.login.username.focus();",
                "document.login.username.value = \"" + login + "\";"
                + "document.login.password.value = \"" + senha + "\";"
                + "doLogin();");
        // Convert body to InputStream
        in = new ByteArrayInputStream(body.getBytes("UTF-8"));

        // A Reader should be created with the correct charset,
        // which may be obtained from the Content-Type header
        // of an HTTP response.
        Reader reader = new InputStreamReader(in);

        // InputSourceImpl constructor with URI recommended
        // so the renderer can resolve page component URLs.
        InputSource is = new InputSourceImpl(reader, uri);
        HtmlPanel htmlPanel = new HtmlPanel();
        UserAgentContext ucontext = new LocalUserAgentContext();
        HtmlRendererContext rendererContext =
                new LocalHtmlRendererContext(htmlPanel, ucontext);

        // Set a preferred width for the HtmlPanel,
        // which will allow getPreferredSize() to
        // be calculated according to block content.
        // We do this here to illustrate the
        // feature, but is generally not
        // recommended for performance reasons.
        htmlPanel.setPreferredWidth(100);

        // Note: This example does not perform incremental
        // rendering while loading the initial document.
        DocumentBuilderImpl builder =
                new DocumentBuilderImpl(
                rendererContext.getUserAgentContext(),
                rendererContext);

        Document document = builder.parse(is);
        in.close();

        // Set the document in the HtmlPanel. This method
        // schedules the document to be rendered in the
        // GUI thread.

        htmlPanel.setDocument(document, rendererContext);
    }

    private static class LocalUserAgentContext
            extends SimpleUserAgentContext {
        // Override methods from SimpleUserAgentContext to
        // provide more accurate information about application.

        public LocalUserAgentContext() {
        }

        @Override
        public String getAppMinorVersion() {
            return "0";
        }

        @Override
        public String getAppName() {
            return "MikrotkHotspotLogin";
        }

        @Override
        public String getAppVersion() {
            return "1";
        }

        @Override
        public String getUserAgent() {
            return "Mozilla/4.0 (compatible;) CobraTest/1.0";
        }
    }

    private static class LocalHtmlRendererContext
            extends SimpleHtmlRendererContext {
        // Override methods from SimpleHtmlRendererContext
        // to provide browser functionality to the renderer.

        public LocalHtmlRendererContext(HtmlPanel contextComponent,
                UserAgentContext ucontext) {
            super(contextComponent, ucontext);
        }

        @Override
        public void linkClicked(HTMLElement linkNode,
                URL url, String target) {
            super.linkClicked(linkNode, url, target);
        }

        @Override
        public HtmlRendererContext open(URL url,
                String windowName, String windowFeatures,
                boolean replace) {
            // This is called on window.open().
            HtmlPanel newPanel = new HtmlPanel();
            HtmlRendererContext newCtx = new LocalHtmlRendererContext(newPanel, this.getUserAgentContext());
            newCtx.navigate(url, "_this");
            return newCtx;
        }
    }
}
