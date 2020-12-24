#case1
class Solution:
    def twosum(self,nums,tgt):
        for i in range(len(nums)):
            for j in range(i+1,len(nums)):
                if nums[i]+nums[j]==tgt:
                    return [i, j]

test=Solution()
ret=test.twosum([12,23,3,44,6,5],29)
print('found elements:{} for tgt'.format(ret)

