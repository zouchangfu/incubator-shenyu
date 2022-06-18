package org.apache.shenyu.common.dto;

import java.util.Objects;

/**
 * this is plugin path vo.
 */
public class PluginPathData {
    /**
     * the plugin local path
     */
    private String path;

    /**
     * the plugin filename
     */
    private String filename;

    /**
     * the plugin server
     */
    private String server;

    /**
     * Gets the value of filename.
     * @return
     */
    public String getFilename() {
        return filename;
    }

    /**
     * Sets the filename.
     * @param filename
     */
    public void setFilename(String filename) {
        this.filename = filename;
    }

    /**
     * Gets the value of local path.
     *
     * @return the value of local path
     */
    public String getPath() {
        return path;
    }

    /**
     * Sets the path.
     *
     * @param path path
     */
    public void setPath(String path) {
        this.path = path;
    }

    /**
     * Gets the value of server.
     *
     * @return the value of server
     */
    public String getServer() {
        return server;
    }

    /**
     * Sets the server.
     *
     * @param server server
     */
    public void setServer(String server) {
        this.server = server;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PluginPathData pluginPathData = (PluginPathData) o;
        return Objects.equals(path, pluginPathData.path) &&
                Objects.equals(filename, pluginPathData.filename) &&
                Objects.equals(server, pluginPathData.server);
    }

    @Override
    public int hashCode() {
        return Objects.hash(path, filename, server);
    }

    @Override
    public String toString() {
        return "PluginPathData{" +
                "path='" + path + '\'' +
                ", filename='" + filename + '\'' +
                ", server='" + server + '\'' +
                '}';
    }
}
