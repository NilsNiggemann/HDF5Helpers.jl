using HDF5Helpers,Test,HDF5
let 

    file1 = tempname()
    file2 = tempname()
    targetfile = tempname()
    targetfile2 = tempname()

    #setup
    h5write(file1,"Group1/0.2/a",1)
    h5write(file1,"Group1/0.2/b",2)
    h5write(file1,"Group1/0.3/c",3)

    
    h5write(file2,"Group1/0.2/a",1)
    h5write(file2,"Group1/0.4/a",5)
    h5write(file2,"Group2/0.4/a",6)
    #merge
    h5merge(targetfile,(file1,file2))

    @testset "standard merge" begin
        h5open(targetfile) do f
            @test read(f["Group1/0.2/a"]) == 1
            @test read(f["Group1/0.2/b"]) == 2
            @test read(f["Group1/0.3/c"]) == 3
            @test read(f["Group1/0.4/a"]) == 5
            @test read(f["Group2/0.4/a"]) == 6
        end
    end
    h5merge(targetfile2,(file1,file2),("1","2"))
    # return read(h5open(targetfile2))
    @testset "Supergroup merge" begin
        h5open(targetfile2) do f
            @test read(f["1/Group1/0.2/a"]) == 1
            @test read(f["1/Group1/0.2/b"]) == 2
            @test read(f["1/Group1/0.3/c"]) == 3
            @test read(f["2/Group1/0.4/a"]) == 5
            @test read(f["2/Group2/0.4/a"]) == 6
        end
    end

    @testset "h5keys" begin
        @test h5keys(targetfile2) == ["1","2"]
        @test h5keys(targetfile2,1) == h5keys(targetfile2,"1") 
        @test h5keys(targetfile2,2,1) == h5keys(targetfile2,"2/Group1")
    end
    @testset "getKeyswith" begin
        @test getKeyswith(file1,"1") == ["Group1"]
        @test getKeyswith(file1,"0.","Group1") == ["0.2","0.3"]
    end

end

