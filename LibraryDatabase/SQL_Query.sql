create schema [LibraryManagementSystem] Authorization [dbo];

use LibMgmSys;


go
--this procedure needs to get the number of copies of 'The Lost Tribe' at 'Sharpstown'
create procedure dbo.getCopyCount @BranchID int, @BookID int, @NoCopies int OUT
as
begin
select @NoCopies = count(*) from BookCopies where BranchID = @BranchID AND BookID = @BookID
return;
end

declare @NoCopies int
--The BookID for the Lost Tribe is 490 and the branch for Sharpstown is 2600
exec dbo.getCopyCount @BranchID = 2600, @BookID = 490, @NoCopies = @NoCopies OUTPUT
print @NoCopies


go
--this procedure will the total copies of the book The Lost Tribe
create procedure dbo.getLostCount @BookID int, @NoCopies int OUT
as
begin
select sum(NoCopies) as 'Total Copies'
from BookCopies where BookID = 490;
return;
end

declare @NoCopies int
--The BookID for The Lost Tribe is 490.
exec dbo.getLostCount @BookID = 490, @NoCopies = @NoCopies OUTPUT
print @NoCopies


go
--This procedure will produce all of the current Borrowers with no Books on loan
create procedure dbo.getNoLoans
as
select Borrower.Name as 'Name', BookLoans.BookID as 'Book On Loan' 
from BookLoans
right join Borrower on BookLoans.CardNo = Borrower.CardNo
where BookLoans.BookID IS NULL 
return;

dbo.getNoLoans


go
--This will produce all books on loan in Sharpstown Library between the Earliest due date on record and the CURRENT_TIMESTAMP
create procedure dbo.getCurrentLoans
as
select Book.Title as 'Title:', Borrower.Name as 'Loaned To:', Borrower.AddressB as 'Loaned Address:' 
from BookLoans
 inner join Book on Book.BookID = BookLoans.BookID
 inner join LibraryBranch on LibraryBranch.BranchID = BookLoans.BranchID
 inner join Borrower on Borrower.CardNo = BookLoans.CardNo
where BranchName = 'Sharpstown'
and DueDate between '2017-08-30' and CURRENT_TIMESTAMP
return;

dbo.getCurrentLoans


go
--this procedure will list the Branch Names as well as the total books on loan for each branch
create procedure dbo.getBranchLoans
as
select LibraryBranch.BranchName as 'Branch Name', COUNT(BookLoans.BookID) as 'Total Loaned Books'
from LibraryBranch
	left join BookLoans on LibraryBranch.BranchID = BookLoans.BranchID
group by LibraryBranch.BranchName
return;

dbo.getBranchLoans


go
--this procedure will show people with more than 5 book on loan and their address.
create procedure dbo.getBookLoanCount
as
select
Borrower.Name as 'Name', Borrower.AddressB as 'Address', Count(BookLoans.BookID) as 'Total On Loan'
from Borrower
	left join BookLoans on Borrower.CardNo = BookLoans.CardNo
group by Borrower.Name, Borrower.AddressB
having Count(BookLoans.BookID) > 5
return;

dbo.getBookLoanCount


go
--this procedure will list the number of copies of all Stephen King books at Central Library.
create procedure dbo.getCopiesCentral
as
select
Book.Title as 'Title', Count(BookCopies.NoCopies) as 'Number of Copies'
from BookCopies
	left join Book on Book.BookID = BookCopies.BookID
	right join LibraryBranch on BookCopies.BranchID = LibraryBranch.BranchID
where Book.BookID = 500
	OR Book.BookID = 510
	AND LibraryBranch.BranchName = 'Central'
Group By Book.Title
return;

dbo.getCopiesCentral