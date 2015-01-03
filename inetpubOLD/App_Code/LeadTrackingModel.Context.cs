﻿//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;

public partial class LeadTrackingProgram2Entities2 : DbContext
{
    public LeadTrackingProgram2Entities2()
        : base("name=LeadTrackingProgram2Entities2")
    {
    }

    protected override void OnModelCreating(DbModelBuilder modelBuilder)
    {
        throw new UnintentionalCodeFirstException();
    }

    public DbSet<ActionStatu> ActionStatus { get; set; }
    public DbSet<BloodResult> BloodResults { get; set; }
    public DbSet<Classification> Classifications { get; set; }
    public DbSet<CleanUpStatu> CleanUpStatus { get; set; }
    public DbSet<ConstructionType> ConstructionTypes { get; set; }
    public DbSet<Family> Families { get; set; }
    public DbSet<FPLinkType> FPLinkTypes { get; set; }
    public DbSet<Lab> Labs { get; set; }
    public DbSet<Language> Languages { get; set; }
    public DbSet<LeadValueCategory> LeadValueCategories { get; set; }
    public DbSet<Medium> Media { get; set; }
    public DbSet<Note> Notes { get; set; }
    public DbSet<NoteType> NoteTypes { get; set; }
    public DbSet<Person> People { get; set; }
    public DbSet<PersonToProperty> PersonToProperties { get; set; }
    public DbSet<Property> Properties { get; set; }
    public DbSet<PropertyToCleanUpStatu> PropertyToCleanUpStatus { get; set; }
    public DbSet<PropertyToNote> PropertyToNotes { get; set; }
    public DbSet<Questoinaire> Questoinaires { get; set; }
    public DbSet<ReleaseStatu> ReleaseStatus { get; set; }
    public DbSet<Sample> Samples { get; set; }
    public DbSet<SampleType> SampleTypes { get; set; }
    public DbSet<SeedTable> SeedTables { get; set; }
    public DbSet<Status> Status { get; set; }
}