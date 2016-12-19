/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mmc.BICommentary;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Calendar;
import java.util.Date;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author rsahay
 */
@Entity
@Table(name = "REPORTING_COMMNETARY", catalog = "", schema = "OBIEE")
@XmlRootElement
@NamedQueries({
    @NamedQuery(name = "ReportingCommnetary.findAll", query = "SELECT r FROM ReportingCommnetary r"),
    @NamedQuery(name = "ReportingCommnetary.findByCommentaryId", query = "SELECT r FROM ReportingCommnetary r WHERE r.commentaryId = :commentaryId"),
    @NamedQuery(name = "ReportingCommnetary.findByAppName", query = "SELECT r FROM ReportingCommnetary r WHERE r.appName = :appName"),
    @NamedQuery(name = "ReportingCommnetary.findByAppSubName", query = "SELECT r FROM ReportingCommnetary r WHERE r.appSubName = :appSubName"),
    @NamedQuery(name = "ReportingCommnetary.findByUserName", query = "SELECT r FROM ReportingCommnetary r WHERE r.userName = :userName"),
    @NamedQuery(name = "ReportingCommnetary.findByLastUpdateDate", query = "SELECT r FROM ReportingCommnetary r WHERE r.lastUpdateDate = :lastUpdateDate")})
public class ReportingCommnetary implements Serializable {

    private static final long serialVersionUID = 1L;
    // @Max(value=?)  @Min(value=?)//if you know range of your decimal fields consider using these annotations to enforce field validation
    @Id
    //@SequenceGenerator(name = "REPORTING_COMMNETARY_seq", sequenceName = "REPORTING_COMMNETARY_seq", schema = "OBIEE", allocationSize = 1)
    //@GeneratedValue(generator = "REPORTING_COMMNETARY_seq")
    @Basic(optional = false)
    @NotNull
    @Column(name = "COMMENTARY_ID")
    private BigDecimal commentaryId;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 200)
    @Column(name = "APP_NAME")
    private String appName;
    @Size(max = 2000)
    @Column(name = "APP_SUB_NAME")
    private String appSubName;
    @Basic(optional = false)
    @NotNull
    @Size(min = 1, max = 250)
    @Column(name = "USER_NAME")
    private String userName;
    @Column(name = "LAST_UPDATE_DATE")
    @Temporal(TemporalType.TIMESTAMP)
    private Calendar lastUpdateDate;
    @Lob
    @Column(name = "COMMENTARY")
    private String commentary;
    @Lob
    @Column(name = "PARAMETER")
    private String parameter;

    public ReportingCommnetary() {
    }

    public ReportingCommnetary(BigDecimal commentaryId) {
        this.commentaryId = commentaryId;
    }

    public ReportingCommnetary(BigDecimal commentaryId, String appName, String userName) {
        this.commentaryId = commentaryId;
        this.appName = appName;
        this.userName = userName;
    }

    public BigDecimal getCommentaryId() {
        return commentaryId;
    }

    public void setCommentaryId(BigDecimal commentaryId) {
        this.commentaryId = commentaryId;
    }

    public String getAppName() {
        return appName;
    }

    public void setAppName(String appName) {
        this.appName = appName;
    }

    public String getAppSubName() {
        return appSubName;
    }

    public void setAppSubName(String appSubName) {
        this.appSubName = appSubName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Calendar getLastUpdateDate() {
        return lastUpdateDate;
    }

    public void setLastUpdateDate(Calendar lastUpdateDate) {
        this.lastUpdateDate = lastUpdateDate;
    }

    public String getCommnetary() {
        return commentary;
    }

    public void setCommnetary(String commentary) {
        this.commentary = commentary;
    }

    public String getParameter() {
        return parameter;
    }

    public void setParameter(String parameter) {
        this.parameter = parameter;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (commentaryId != null ? commentaryId.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof ReportingCommnetary)) {
            return false;
        }
        ReportingCommnetary other = (ReportingCommnetary) object;
        if ((this.commentaryId == null && other.commentaryId != null) || (this.commentaryId != null && !this.commentaryId.equals(other.commentaryId))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "com.mmc.BICommentary.ReportingCommnetary[ commentaryId=" + commentaryId + " ]";
    }
    
}
