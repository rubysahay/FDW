/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.mmc.BICommentary.services;

import com.mmc.BICommentary.ReportingCommnetary;
import java.math.BigDecimal;
import java.util.Calendar;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.ParameterMode;
import javax.persistence.PersistenceContext;
import javax.persistence.StoredProcedureQuery;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

/**
 *
 * @author rsahay
 */
@Stateless
    @Path("/reportingcommentary/")
public class ReportingCommnetaryFacadeREST extends AbstractFacade<ReportingCommnetary> {

    @PersistenceContext(unitName = "BiCommentaryPU")
    private EntityManager em;

    public ReportingCommnetaryFacadeREST() {
        super(ReportingCommnetary.class);
    }

    @POST
    @Override
    @Consumes({MediaType.APPLICATION_JSON})
    @Produces({MediaType.APPLICATION_JSON})
    public Response create(ReportingCommnetary entity) {
       // OBIEE.MMC_OBIEE_Reporting_Commentary
        System.out.println("Proc Execution Started");
        StoredProcedureQuery storedProcedure
        = em.createStoredProcedureQuery("OBIEE.MMC_OBIEE_Reporting_Commentary", String.class, String.class,String.class,String.class,String.class,Calendar.class);
        storedProcedure
                .registerStoredProcedureParameter("p_app_name", String.class, ParameterMode.IN)
                .registerStoredProcedureParameter("p_app_sub_name", String.class, ParameterMode.IN)
                .registerStoredProcedureParameter("p_commentary", String.class, ParameterMode.IN)
                .registerStoredProcedureParameter("p_parameter", String.class, ParameterMode.IN)
                .registerStoredProcedureParameter("p_user_name", String.class, ParameterMode.IN)
                .registerStoredProcedureParameter("p_last_update_date", Calendar.class, ParameterMode.IN)
                .registerStoredProcedureParameter("ERRBUF", String.class, ParameterMode.OUT)
                .registerStoredProcedureParameter("RETCODE", Integer.class, ParameterMode.OUT)
                .setParameter("p_app_name", entity.getAppName())
                .setParameter("p_app_sub_name", entity.getAppSubName())
                .setParameter("p_commentary", entity.getCommnetary())
                .setParameter("p_parameter", entity.getParameter())
                .setParameter("p_user_name", entity.getUserName())
                .setParameter("p_last_update_date", entity.getLastUpdateDate())                
                .setParameter("ERRBUF", "OK")
                .setParameter("RETCODE", 0);

       // System.out.println ("Param : "+entity.getAppName());
        storedProcedure.execute();
        System.out.println("Proc Executed");

      //  String l_cols_text = (String) storedProcedure.getOutputParameterValue("p_cols_out");
        //String l_ERRBUF = (String) storedProcedure.getOutputParameterValue("ERRBUF");
        Integer l_retCode = (Integer) storedProcedure.getOutputParameterValue("RETCODE");
        
        System.out.println("l_ERRBUF: " +l_retCode);

       // if (!l_ERRBUF.equals("OK")) {
        if (!l_retCode.equals(0)) {
            return Response.serverError().build();
        }
      //  super.create(entity);     
       return Response.ok().build();
    }

    @PUT
    @Path("{id}")
    @Consumes({MediaType.APPLICATION_XML, MediaType.APPLICATION_JSON})
    public void edit(@PathParam("id") BigDecimal id, ReportingCommnetary entity) {
        super.edit(entity);
    }

    @DELETE
    @Path("{id}")
    public void remove(@PathParam("id") BigDecimal id) {
        super.remove(super.find(id));
    }

    @GET
    @Path("{id}")
    @Produces({MediaType.APPLICATION_JSON,MediaType.APPLICATION_XML})
    public ReportingCommnetary find(@PathParam("id") BigDecimal id) {
        return super.find(id);
    }

    @GET
    @Override
    @Produces({MediaType.APPLICATION_JSON})
    public List<ReportingCommnetary> findAll() {
        return super.findAll();
    }

    @GET
    @Path("{from}/{to}")
    @Produces({MediaType.APPLICATION_XML, MediaType.APPLICATION_JSON})
    public List<ReportingCommnetary> findRange(@PathParam("from") Integer from, @PathParam("to") Integer to) {
        return super.findRange(new int[]{from, to});
    }

    @GET
    @Path("count")
    @Produces(MediaType.TEXT_PLAIN)
    public String countREST() {
        return String.valueOf(super.count());
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }
    
}
